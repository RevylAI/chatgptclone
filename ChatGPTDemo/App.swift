import SwiftUI

@main struct DemoApp: App {
    @StateObject private var store = Store()
    var body: some Scene { WindowGroup {RootView().environmentObject(store).preferredColorScheme(store.theme).tint(.primary)} }
}
struct RootView: View {
    @EnvironmentObject var store: Store
    @State var modal: String?
    var body: some View {
        ZStack(alignment:.top) {
            pageColor.ignoresSafeArea()
            if !store.state.welcomed {WelcomeView()}
            else if store.sidebar {SidebarView(modal:$modal)}
            else if store.destination == "images" {ImagesView(modal:$modal)}
            else {ChatView(modal:$modal)}
            if let toast=store.toast {Text(toast).font(.system(size:14,weight:.medium)).padding(.horizontal,22).padding(.vertical,14).background(.regularMaterial,in:Capsule()).shadow(radius:8).padding(.top,56).allowsHitTesting(false)}
        }
        .sheet(item: Binding(get:{modal.map(Modal.init)},set:{modal=$0?.id})){item in
            switch item.id {
            case "auth":AuthView()
            case "settings":SettingsView()
            case "project":ProjectEditor()
            case "voice":VoiceView()
            case "tools":ToolsView {mode in NotificationCenter.default.post(name:.demoMode,object:mode)}
            case "temporary":TemporaryInfo()
            case "upgrade":UpgradeView()
            case "group":GroupInfo()
            default:Text(item.id)
            }
        }
        .onAppear {if store.destination=="settings"{store.destination="chat";modal="settings"}}
    }
}
struct Modal: Identifiable {let id:String;init(_ id:String){self.id=id}}
extension Notification.Name {static let demoMode = Notification.Name("demoMode")}
