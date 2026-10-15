import SwiftUI
import Foundation

struct Message: Codable, Identifiable, Equatable {
    var id = UUID()
    var text: String
    var isUser: Bool
    var image: String? = nil
}
struct Conversation: Codable, Identifiable, Equatable {
    var id = UUID()
    var title: String
    var messages: [Message] = []
    var archived = false
    var projectID: UUID? = nil
}

struct ChatSearchResult: Identifiable {
    let conversation: Conversation
    let snippet: String
    var id: UUID { conversation.id }
}

extension Conversation {
    /// Search saved, active conversations without storing a second copy of their content.
    func searchResult(for query: String) -> ChatSearchResult? {
        guard !archived else { return nil }
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        func match(in text: String) -> Range<String.Index>? {
            text.range(of: query, options: [.caseInsensitive, .diacriticInsensitive])
        }
        let matchingMessage = query.isEmpty ? nil : messages.first { match(in: $0.text) != nil }
        guard query.isEmpty || match(in: title) != nil || matchingMessage != nil else { return nil }
        let source = matchingMessage?.text ?? messages.last?.text ?? "No messages yet"
        let text = source.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
        // Keep the matched phrase visible even when it occurs deep inside a long reply.
        let range = query.isEmpty ? nil : match(in: text)
        let start = range.map { text.index($0.lowerBound, offsetBy: -45, limitedBy: text.startIndex) ?? text.startIndex } ?? text.startIndex
        let end = text.index(start, offsetBy: max(160, query.count + 45), limitedBy: text.endIndex) ?? text.endIndex
        let snippet = (start == text.startIndex ? "" : "…") + String(text[start..<end]) + (end == text.endIndex ? "" : "…")
        return ChatSearchResult(conversation: self, snippet: snippet)
    }
}
struct Project: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var symbol = "folder"
    var color = "Blue"
    var instructions = ""
    var sources: [String] = []
    var sourceContents: [String: String]? = [:]
}
struct LocalState: Codable {
    var welcomed = false
    var signedIn = false
    var name = "Alex Smith"
    var email = "alex@example.com"
    var username = "alexsmith.mobbin1"
    var conversations: [Conversation] = []
    var projects: [Project] = []
    var appearance = "System"
    var accent = "Default"
    var instructions = ""
    var nickname = ""
    var occupation = ""
    var tone = "Default"
    var haptics = true
    var correctSpelling = true
    var memory = true
    var history = true
    var improveModel = false
    var voice = "Arbor"
}
struct LaunchOptions {
    var bypass = false
    var seed = false
    var resetToken: String? = nil
    var screen: String? = nil
    init(environment: [String: String] = ProcessInfo.processInfo.environment, arguments: [String] = ProcessInfo.processInfo.arguments) {
        func value(_ key: String) -> String? {
            if let x = environment[key] { return x }
            if let i = arguments.firstIndex(of: "-" + key), i + 1 < arguments.count { return arguments[i + 1] }
            return nil
        }
        #if DEMO_MODE
        bypass = ["1", "true"].contains(value("DEMO_AUTH_BYPASS") ?? "")
        seed = ["1", "true"].contains(value("DEMO_SEED_DATA") ?? "")
        resetToken = value("DEMO_RESET_TOKEN")
        screen = value("DEMO_SCREEN")
        #endif
    }
}
@MainActor final class Store: ObservableObject {
    @Published var state: LocalState
    @Published var selectedChat: UUID?
    @Published var selectedProject: UUID?
    @Published var sidebar = false
    @Published var destination = "chat"
    @Published var temporary = false
    @Published var temporaryMessages: [Message] = []
    @Published var toast: String?
    let defaults: UserDefaults
    init(defaults: UserDefaults = .standard, options: LaunchOptions = LaunchOptions()) {
        self.defaults = defaults
        if let token = options.resetToken, defaults.string(forKey: "resetToken") != token {
            defaults.removeObject(forKey: "state")
            defaults.set(token, forKey: "resetToken")
        }
        state = defaults.data(forKey: "state").flatMap { try? JSONDecoder().decode(LocalState.self, from: $0) } ?? LocalState()
        if options.bypass { state.signedIn = true; state.welcomed = true }
        if options.seed && state.projects.isEmpty && state.conversations.isEmpty {
            state.projects = [Project(name: "Recipe", symbol: "popcorn", color: "Red"), Project(name: "UI UX", symbol: "pencil.tip.crop.circle", color: "Blue")]
            state.conversations = [Conversation(title: "Cafe Mocha Recipe", messages: [Message(text: "Help me create a cafe mocha recipe", isUser: true), Message(text: Self.coffeeReply, isUser: false)], projectID: state.projects[0].id), Conversation(title: "Test Confirmation", messages: [Message(text:"Hello",isUser:true),Message(text:"Hey there! What’s on your mind today?",isUser:false)])]
        }
        if let screen = options.screen {
            if screen == "sidebar" { sidebar = true }
            else if screen == "recipe" { selectedChat = state.conversations.first?.id }
            else if screen == "project" { selectedProject = state.projects.last?.id }
            else { destination = screen }
        }
        save()
    }
    var currentChat: Conversation? { state.conversations.first { $0.id == selectedChat } }
    var project: Project? { state.projects.first { $0.id == selectedProject } }
    var messages: [Message] { temporary ? temporaryMessages : currentChat?.messages ?? [] }
    func searchChats(_ query: String) -> [ChatSearchResult] {
        state.conversations.compactMap { $0.searchResult(for: query) }
    }
    var theme: ColorScheme? { state.appearance == "Dark" ? .dark : state.appearance == "Light" ? .light : nil }
    var initials: String { state.name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined() }
    func save() { if let data = try? JSONEncoder().encode(state) { defaults.set(data, forKey: "state") } }
    func signIn(email: String, name: String? = nil) { state.signedIn = true; state.welcomed = true; state.email = email; if let name, !name.isEmpty { state.name = name }; save() }
    func signOut() { state.signedIn = false; selectedChat = nil; selectedProject = nil; sidebar = false; destination = "chat"; save() }
    func newChat() { selectedChat = nil; selectedProject = nil; temporary = false; temporaryMessages = []; destination = "chat"; sidebar = false }
    func open(_ chat: Conversation) { selectedChat = chat.id; selectedProject = nil; temporary = false; destination = "chat"; sidebar = false }
    func send(_ text: String, mode: String = "") {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let reply = Self.reply(text, mode: mode)
        let pair = [Message(text:text,isUser:true), Message(text:reply,isUser:false,image:mode == "Image" ? "Coffee" : nil)]
        if temporary { temporaryMessages += pair; return }
        if let i = state.conversations.firstIndex(where: {$0.id == selectedChat}) { state.conversations[i].messages += pair }
        else {
            let title = text.localizedCaseInsensitiveContains("mocha") ? "Cafe Mocha Recipe" : String(text.prefix(42))
            let chat = Conversation(title:title,messages:pair,projectID:selectedProject)
            state.conversations.insert(chat,at:0); selectedChat = chat.id
        }
        save()
    }
    func archive(_ id: UUID) { if let i=state.conversations.firstIndex(where:{$0.id==id}) { state.conversations[i].archived = true }; if selectedChat == id { newChat() };save() }
    func unarchive(_ id: UUID) { if let i=state.conversations.firstIndex(where:{$0.id==id}) { state.conversations[i].archived = false }; save() }
    func deleteChat(_ id: UUID) { state.conversations.removeAll{$0.id==id}; if selectedChat==id {newChat()}; save() }
    func renameChat(_ id: UUID, _ title: String) { guard !title.trimmingCharacters(in:.whitespaces).isEmpty else{return};if let i=state.conversations.firstIndex(where:{$0.id==id}){state.conversations[i].title=title};save() }
    func addProject(name: String, symbol: String, color: String) { let p=Project(name:name,symbol:symbol,color:color);state.projects.append(p);selectedProject=p.id;selectedChat=nil;sidebar=false;destination="chat";save() }
    func updateProject(_ project: Project) { if let i=state.projects.firstIndex(where:{$0.id==project.id}) {state.projects[i]=project};save() }
    @discardableResult func saveSource(title: String, text: String, replacing oldName: String? = nil) -> String? {
        guard var project, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = title.isEmpty ? "Note" : title
        let stem = base.hasSuffix(".txt") ? String(base.dropLast(4)) : base
        var filename = stem + ".txt"
        var suffix = 2
        while project.sources.contains(filename) && filename != oldName {
            filename = "\(stem) (\(suffix)).txt"; suffix += 1
        }
        if let oldName, let index = project.sources.firstIndex(of: oldName) {
            project.sources[index] = filename
            project.sourceContents?.removeValue(forKey: oldName)
        } else { project.sources.append(filename) }
        if project.sourceContents == nil { project.sourceContents = [:] }
        project.sourceContents?[filename] = text
        updateProject(project)
        return filename
    }
    func removeSource(_ filename: String) {
        guard var project else { return }
        project.sources.removeAll { $0 == filename }
        project.sourceContents?.removeValue(forKey: filename)
        updateProject(project)
    }
    func deleteProject(_ id: UUID) { state.projects.removeAll{$0.id==id}; for i in state.conversations.indices where state.conversations[i].projectID==id {state.conversations[i].projectID=nil};newChat();save() }
    func notice(_ text: String) { toast=text;Task {try? await Task.sleep(for:.seconds(2));if toast==text{toast=nil}} }
    static func reply(_ text: String, mode: String) -> String {
        if mode == "Image" { return "Image created" }
        if text.localizedCaseInsensitiveContains("mocha") || text.localizedCaseInsensitiveContains("coffee") {return coffeeReply}
        if text.localizedCaseInsensitiveContains("UI") || text.localizedCaseInsensitiveContains("design") { return "UI/UX design is all about how digital products look and feel—and how easy they are to use.\n\n**UI (User Interface)** is the visual part: buttons, colors, and layout.\n\n**UX (User Experience)** is how smoothly everything works together.\n\nGood design makes a product clear, useful, and enjoyable. Start with your users, sketch an idea, test it, and improve it." }
        if mode == "Research" {return "**Research overview**\n\n1. Define the question and the information you need.\n2. Compare several reliable sources.\n3. Summarize the findings and note uncertainties.\n\nThis is a locally generated demonstration report. No online research was performed."}
        return "Hey there! I can help you brainstorm, write, learn, or plan.\n\nHere’s a simple way to get started:\n\n• Tell me what you’d like to achieve.\n• Add any details that matter.\n• We’ll work through it together.\n\nWhat would you like to explore next?"
    }
    static let coffeeReply = """
A good café mocha is all about balancing three things: rich espresso, smooth chocolate, and creamy milk. Here’s a simple way to make one at home that tastes like a café version.

**☕ Classic Café Mocha Recipe**

**Ingredients (1 serving)**
• 1 shot espresso (or 60 ml strong coffee)
• 200 ml milk (dairy or plant-based)
• 1–2 tbsp chocolate syrup or cocoa powder
• 1 tsp sugar (optional, adjust to taste)
• Whipped cream (optional, for topping)

**How to make it**
1. Brew your espresso or strong coffee.
2. Mix in the chocolate until smooth.
3. Heat and froth the milk.
4. Pour the milk into the coffee-chocolate mixture.
5. Add whipped cream and sprinkle with cocoa.

**☕ Easy Variations**
• **Iced Mocha:** Use cold milk + ice, skip frothing.
• **Dark Mocha:** Use dark chocolate for a deeper flavor.
• **Vegan Mocha:** Use oat or almond milk.
• **Mint Mocha:** Add a drop of peppermint extract.

**💡 Pro Tips**
• Use **high-quality cocoa or chocolate**—this makes the biggest difference.
• If your mocha tastes flat, add a **tiny pinch of salt** to enhance the chocolate.
• For extra richness, mix in a little **cream with milk**.

If you want, I can tailor this into a **coffee shop-style recipe (like Starbucks)** or help you create your own **signature mocha flavor**.
"""
}
