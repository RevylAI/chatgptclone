import SwiftUI

struct ChatView:View {
    @EnvironmentObject var store:Store
    @Binding var modal:String?
    @State var draft=""
    @State var mode=""
    @State var rename=""
    @State var showRename=false
    @State var confirmDelete=false
    @State var confirmArchive=false
    @State var projectEdit=false
    @State var projectInstructions=false
    @State var sourceSheet: SourceSheet?
    @State var projectTab="Chats"
    @State var projectDelete=false
    @FocusState var focused:Bool
    var isProject:Bool {store.project != nil && store.selectedChat == nil}
    var body:some View {
        VStack(spacing:0){
            header.padding(.horizontal,16).padding(.top,0)
            if isProject {projectContent}
            else if store.messages.isEmpty {
                Spacer()
                if store.temporary {VStack(spacing:7){Text("Temporary chat").font(.system(size:17,weight:.medium));Text("This chat won’t appear in your history, and won’t be used to train our models.").font(.system(size:14)).foregroundStyle(.secondary).multilineTextAlignment(.center)}.frame(width:260);Spacer()}
                if !focused && !store.temporary {suggestions}
            } else {
                ScrollViewReader{proxy in
                    ScrollView{LazyVStack(alignment:.leading,spacing:26){ForEach(store.messages){message in messageView(message)};Color.clear.frame(height:10).id("bottom")}.padding(.horizontal,16).padding(.top,18)}
                        .scrollDismissesKeyboard(.interactively)
                        .onChange(of:store.messages.count){_,_ in withAnimation{proxy.scrollTo("bottom",anchor:.bottom)}}
                }
            }
            composer.padding(.horizontal,32).padding(.top,14).padding(.bottom,0)
        }.background(pageColor)
        .onReceive(NotificationCenter.default.publisher(for:.demoMode)){note in if let m=note.object as? String {mode=m;focused=true}}
        .alert("Rename chat",isPresented:$showRename){TextField("Title",text:$rename);Button("Cancel",role:.cancel){};Button("Save"){if let id=store.selectedChat{store.renameChat(id,rename)}}}
        .alert("Archive Chat",isPresented:$confirmArchive){Button("Cancel",role:.cancel){};Button("Archive"){if let id=store.selectedChat{store.archive(id)}}}message:{Text("You can view this chat in Settings.")}
        .alert("Delete Chat",isPresented:$confirmDelete){Button("Cancel",role:.cancel){};Button("Delete",role:.destructive){if let id=store.selectedChat{store.deleteChat(id)}}}message:{Text("This chat will be removed from local history.")}
        .alert("Delete project?",isPresented:$projectDelete){Button("Cancel",role:.cancel){};Button("Delete project",role:.destructive){if let id=store.selectedProject{store.deleteProject(id)}}}
        .sheet(isPresented:$projectEdit){ProjectEditor(existing:store.project)}
        .sheet(isPresented:$projectInstructions){ProjectInstructions() .presentationDetents([.medium])}
        .sheet(item:$sourceSheet){sheet in SourceEditor(existing:sheet.filename)}
    }
    var header:some View {
        HStack {
            RoundButton(symbol:"line.3.horizontal.decrease",label:"Open sidebar"){focused=false;store.sidebar=true}
            Spacer()
            if !store.state.signedIn {Button("Sign up"){modal="auth"}.font(.system(size:14,weight:.semibold)).foregroundStyle(pageColor).padding(.horizontal,17).padding(.vertical,11).background(Color.primary,in:Capsule()).buttonStyle(.plain)}
            else if isProject {
                HStack(spacing:0){ShareLink(item: "Project: \(store.project?.name ?? "")\n\n\(store.project?.instructions ?? "")") { Image(systemName:"square.and.arrow.up").font(.system(size:21)).frame(width:44,height:44) }.accessibilityLabel("Share project");Menu{Button("Edit project",systemImage:"pencil"){projectEdit=true};Button("Edit instructions",systemImage:"slider.horizontal.3"){projectInstructions=true};Button("Delete project",systemImage:"trash",role:.destructive){projectDelete=true}}label:{Image(systemName:"ellipsis").frame(width:44,height:44)}.accessibilityLabel("Project menu")}.background(pageColor,in:Capsule()).shadow(color:.black.opacity(0.04),radius:14,y:7)
            } else if !store.messages.isEmpty {
                HStack(spacing:0){RoundButton(symbol:"square.and.pencil",label:"New chat",floating:false){store.newChat();draft=""};Menu {
                    ShareLink(item: store.messages.map { ($0.isUser ? "You: " : "ChatGPT: ") + $0.text }.joined(separator:"\n\n")) { Label("Share",systemImage:"square.and.arrow.up") }
                    Menu("Add to project",systemImage:"folder") {ForEach(store.state.projects){p in Button(p.name){if let i=store.state.conversations.firstIndex(where:{$0.id==store.selectedChat}){store.state.conversations[i].projectID=p.id;store.save();store.notice("Added to \(p.name)")}}}}
                    Button("Rename",systemImage:"pencil"){rename=store.currentChat?.title ?? "";showRename=true}
                    Button("Archive",systemImage:"archivebox"){confirmArchive=true}
                    Button("Delete",systemImage:"trash",role:.destructive){confirmDelete=true}
                }label:{Image(systemName:"ellipsis").frame(width:44,height:44)}.accessibilityLabel("Chat menu")}.background(pageColor,in:Capsule()).shadow(color:.black.opacity(0.04),radius:14,y:7)
            } else {
                HStack(spacing:0){RoundButton(symbol:"person.badge.plus",label:"Start group chat",floating:false){modal="group"};RoundButton(symbol:store.temporary ? "bubble.right.fill":"bubble.right.dashed",label:"Temporary chat",floating:false){if store.temporary{store.temporary=false}else{modal="temporary"}}}.background(pageColor,in:Capsule()).shadow(color:.black.opacity(0.04),radius:14,y:7)
            }
        }.frame(height:48)
    }
    var suggestions:some View {
        ScrollView(.horizontal,showsIndicators:false){HStack(spacing:12){suggestion("Create an image","for my presentation","Create an image for my presentation");suggestion("ChatGPT starter guide","with a simple example","How can I use ChatGPT?");suggestion("Write a short story","tailored to my favorite genre","Write a short story")}.padding(.horizontal,12)}.frame(height:83)
    }
    func suggestion(_ title:String,_ subtitle:String,_ prompt:String)->some View {Button{draft=prompt;focused=true}label:{VStack(alignment:.leading,spacing:4){Text(title).font(.system(size:15,weight:.semibold));Text(subtitle).font(.system(size:15)).foregroundStyle(.secondary)}.padding(16).frame(height:80,alignment:.top).background(secondaryColor.opacity(0.4),in:RoundedRectangle(cornerRadius:18))}.buttonStyle(.plain)}
    var composer:some View {
        VStack(alignment:.leading,spacing:4){
            if !mode.isEmpty {Button{mode=""}label:{Label(mode+"  ×",systemImage:mode=="Image" ? "photo":"sparkles").font(.system(size:13,weight:.medium)).foregroundStyle(.blue).padding(.horizontal,12).padding(.top,9)}.buttonStyle(.plain)}
            HStack(alignment:.bottom,spacing:12){
                Button{focused=false;modal="tools"}label:{Image(systemName:"plus").font(.system(size:23)).frame(width:30,height:44)}.accessibilityLabel("Add attachment")
                TextField(isProject ? "Message \(store.project?.name ?? "")":store.temporary ? "Temporary chat":mode=="Image" ? "Describe an image":"Ask ChatGPT",text:$draft,axis:.vertical).font(.system(size:17)).lineLimit(1...5).focused($focused).padding(.vertical,12).accessibilityIdentifier("Message input")
                Button{draft="What is UI/UX?";focused=true}label:{Image(systemName:"mic").font(.system(size:20)).foregroundStyle(.secondary).frame(width:22,height:44)}.accessibilityLabel("Dictate")
                Button{if draft.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty{focused=false;modal="voice"}else{store.send(draft,mode:mode);draft="";mode="";focused=false}}label:{Image(systemName:draft.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty ? "waveform":"arrow.up").font(.system(size:18,weight:.semibold)).frame(width:33,height:33).foregroundStyle(pageColor).background(Color.primary,in:Circle()).padding(.vertical,5)}.accessibilityLabel(draft.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty ? "Voice mode":"Send message")
            }
        }.padding(.horizontal,12).background(pageColor,in:RoundedRectangle(cornerRadius:27)).shadow(color:.black.opacity(0.07),radius:19,y:8).overlay(RoundedRectangle(cornerRadius:27).stroke(Color.primary.opacity(0.015))).buttonStyle(.plain)
    }
    func messageView(_ message:Message)->some View {
        VStack(alignment:.leading,spacing:15){
            if message.isUser {HStack{Spacer(minLength:55);Text(message.text).font(.system(size:17)).padding(14).background(secondaryColor,in:RoundedRectangle(cornerRadius:22))}}
            else {
                Text(.init(message.text)).font(.system(size:17)).lineSpacing(6).textSelection(.enabled).fixedSize(horizontal:false,vertical:true)
                if let image=message.image {Image(image).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius:18))}
                HStack(spacing:19){actionIcon("square.on.square","Copy response"){UIPasteboard.general.string=message.text;store.notice("Message copied")};actionIcon("speaker.wave.2","Read aloud"){store.notice("Read aloud preview (local demo)")};actionIcon("hand.thumbsup","Good response"){store.notice("Thank you for your feedback!")};actionIcon("hand.thumbsdown","Bad response"){store.notice("Thank you for your feedback!")};actionIcon("square.and.arrow.up","Share response"){store.notice("Response copied");UIPasteboard.general.string=message.text};Menu{Button("Retry"){store.notice("Response regenerated")};Button("Branch in new chat"){store.newChat();store.send(message.text)}}label:{Image(systemName:"ellipsis")}}.font(.system(size:15)).foregroundStyle(.secondary)
            }
        }
    }
    func actionIcon(_ icon:String,_ label:String,action:@escaping()->Void)->some View{Button(action:action){Image(systemName:icon).frame(minWidth:20,minHeight:30)}.buttonStyle(.plain).accessibilityLabel(label)}
    var projectContent:some View {
        VStack(alignment:.leading,spacing:24){
            HStack(spacing:12){Image(systemName:store.project?.symbol ?? "folder").foregroundStyle(namedColor(store.project?.color ?? "Blue"));Text(store.project?.name ?? "").foregroundStyle(.primary)}.font(.system(size:28)).padding(.top,20)
            HStack(spacing:16){ForEach(["Chats","Sources"],id:\.self){tab in Button{projectTab=tab}label:{Text(tab).font(.system(size:14,weight:projectTab==tab ? .semibold:.regular)).padding(.horizontal,12).padding(.vertical,8).background(projectTab==tab ? secondaryColor:Color.clear,in:Capsule())}.buttonStyle(.plain)}}
            if projectTab=="Chats" {
                let chats=store.state.conversations.filter{$0.projectID==store.selectedProject && !$0.archived}
                if chats.isEmpty {Spacer();EmptyState(symbol:"bubble.left.and.bubble.right",title:"",subtitle:"Project chats will appear here").frame(maxWidth:.infinity);Spacer()}
                else {ScrollView{VStack(alignment:.leading,spacing:26){ForEach(chats){chat in Button{store.open(chat)}label:{VStack(alignment:.leading,spacing:4){Text(chat.title).font(.system(size:17));Text(chat.messages.first?.text ?? "").font(.system(size:15)).foregroundStyle(.secondary).lineLimit(1)}}.buttonStyle(.plain)}}};Spacer()}
            }else{
                if store.project?.sources.isEmpty ?? true {Spacer();EmptyState(symbol:"paperclip",title:"Give ChatGPT more context",subtitle:"Upload files or add notes to give ChatGPT deeper context about your project.").frame(maxWidth:.infinity);Button("Add"){sourceSheet=SourceSheet(nil)}.buttonStyle(.borderedProminent).tint(.primary).frame(maxWidth:.infinity);Spacer()}
                else {Button{sourceSheet=SourceSheet(nil)}label:{Label("Add sources",systemImage:"plus")}.buttonStyle(.plain);ForEach(store.project?.sources ?? [],id:\.self){s in HStack{Image(systemName:"doc.text").foregroundStyle(.blue);Button(s){sourceSheet=SourceSheet(s)}.buttonStyle(.plain);Spacer();Button{store.removeSource(s)}label:{Image(systemName:"trash").foregroundStyle(.secondary)}.accessibilityLabel("Remove \(s)")}};Spacer()}
            }
        }.padding(.horizontal,24)
    }
}

struct SidebarView:View {
    @EnvironmentObject var store:Store
    @Binding var modal:String?
    @State var search=""
    @State var searching=false
    @State var renamed:UUID?
    @State var title=""
    var chats:[Conversation] {store.state.conversations.filter{!$0.archived && (search.isEmpty || $0.title.localizedCaseInsensitiveContains(search))}}
    var body:some View {
        VStack(spacing:0){
            HStack{
                if searching{Image(systemName:"magnifyingglass");TextField("Search",text:$search).accessibilityIdentifier("Search chats");Button{searching=false;search=""}label:{Image(systemName:"xmark")}.accessibilityLabel("Close search")}
                else{Text("ChatGPT").font(.system(size:22,weight:.semibold));Spacer();RoundButton(symbol:"magnifyingglass",label:"Search chats"){searching=true};Button{modal=store.state.signedIn ? "settings":"auth"}label:{Avatar(initials:store.state.signedIn ? store.initials:"",size:30)}.buttonStyle(.plain).accessibilityLabel(store.state.signedIn ? "Settings":"Log in")}
            }.padding(.horizontal,24).frame(height:54).padding(.top,4)
            ScrollView{
                VStack(alignment:.leading,spacing:0){
                    if !searching {
                        sideRow("photo.on.rectangle.angled","Images"){store.sidebar=false;store.destination="images"}
                        sideRow("square.grid.2x2","Apps"){store.notice("Connected services are mocked in this demo")}
                        Text("Projects").font(.system(size:16,weight:.semibold)).padding(.top,30).padding(.bottom,14)
                        sideRow("folder.badge.plus","New project"){modal=store.state.signedIn ? "project":"auth"}
                    }
                    ForEach(store.state.projects.filter{search.isEmpty || $0.name.localizedCaseInsensitiveContains(search)}){p in sideRow(p.symbol,p.name,color:namedColor(p.color)){store.selectedProject=p.id;store.selectedChat=nil;store.sidebar=false;store.destination="chat"}}
                    if !chats.isEmpty {Text("Recents").font(.system(size:16,weight:.semibold)).padding(.top,28).padding(.bottom,14)}
                    ForEach(chats){chat in Button{store.open(chat)}label:{Text(chat.title).font(.system(size:17)).frame(maxWidth:.infinity,alignment:.leading).padding(.vertical,14).contentShape(Rectangle())}.buttonStyle(.plain).contextMenu{Button("Rename"){renamed=chat.id;title=chat.title};Button("Archive"){store.archive(chat.id)};Button("Delete",role:.destructive){store.deleteChat(chat.id)}}}
                }.padding(.horizontal,24)
            }
            if chats.isEmpty && store.state.projects.isEmpty {Text(searching ? "No results":"Once you start chatting, your\nconversations will appear here.").font(.system(size:17)).foregroundStyle(.secondary).multilineTextAlignment(.center).frame(maxHeight:.infinity)}
            HStack{Spacer();Button{store.newChat()}label:{Label("Chat",systemImage:"square.and.pencil").font(.system(size:17,weight:.semibold)).foregroundStyle(pageColor).padding(.horizontal,23).padding(.vertical,16).background(Color.primary,in:Capsule()).shadow(color:.black.opacity(0.15),radius:12,y:5)}.buttonStyle(.plain).accessibilityLabel("New chat")}.padding(.horizontal,24).padding(.bottom,-7)
        }.alert("Rename chat",isPresented:Binding(get:{renamed != nil},set:{if !$0{renamed=nil}})){TextField("Title",text:$title);Button("Cancel",role:.cancel){renamed=nil};Button("Save"){if let id=renamed{store.renameChat(id,title)};renamed=nil}}
    }
    func sideRow(_ icon:String,_ title:String,color:Color = .primary,action:@escaping()->Void)->some View {Button(action:action){HStack(spacing:14){Image(systemName:icon).font(.system(size:21)).foregroundStyle(color).frame(width:22);Text(title).font(.system(size:17));Spacer()}.frame(height:48).contentShape(Rectangle())}.buttonStyle(.plain)}
}

struct SourceSheet: Identifiable {
    let filename: String?
    var id: String { filename ?? "new-source" }
    init(_ filename: String?) { self.filename = filename }
}
