import SwiftUI
struct SettingsView:View {
    @EnvironmentObject var store:Store
    @Environment(\.dismiss) var dismiss
    @State var page="Settings"
    @State var editProfile=false
    @State var logout=false
    @State var upgrade=false
    var body:some View {
        VStack(spacing:0){
            SheetHeader(title:page,leading:page=="Settings" ? nil:"chevron.left",onLeading:{page="Settings"}){store.save();dismiss()}
            if page=="Archived chats" {archived}
            else {ScrollView{VStack(alignment:.leading,spacing:24){
                if page=="Settings"{settings}
                else if page=="Personalization"{personalization}
                else if page=="Data controls"{dataControls}
                else if page=="Notifications"{notifications}
                else if page=="Security"{security}
                else {EmptyState(symbol:"checkmark.circle",title:page,subtitle:"Your preferences are saved on this device.")}
            }.padding(.horizontal,16).padding(.bottom,30)}}
        }.background(page=="Archived chats" ? pageColor:settingsColor).preferredColorScheme(store.theme).presentationCornerRadius(38).onDisappear{store.save()}
            .sheet(isPresented:$editProfile){ProfileEditor().presentationDetents([.height(460)])}
            .sheet(isPresented:$upgrade){UpgradeView()}
            .alert("Log out of ChatGPT as \(store.state.email)?",isPresented:$logout){Button("Cancel",role:.cancel){};Button("Yes",role:.destructive){store.signOut();dismiss()}}
    }
    var settings:some View {
        Group {
            VStack(spacing:8){Avatar(initials:store.initials,size:88);Text(store.state.name).font(.system(size:28));Text(store.state.username).font(.system(size:16)).foregroundStyle(.secondary);Button("Edit profile"){editProfile=true}.font(.system(size:15)).buttonStyle(.plain).padding(.horizontal,17).padding(.vertical,10).overlay(Capsule().stroke(Color.primary.opacity(0.15)))}.frame(maxWidth:.infinity).padding(.top,35).padding(.bottom,6)
            sectionLabel("Account")
            GroupCard{
                VStack(alignment:.leading,spacing:6){Label("Email",systemImage:"envelope");Text(store.state.email).foregroundStyle(.secondary)}.font(.system(size:17)).frame(maxWidth:.infinity,alignment:.leading).padding(16)
                RowDivider();SettingRow(symbol:"person.badge.shield.checkmark",title:"Age verification"){page="Age verification"}
                RowDivider();SettingRow(symbol:"plus.app",title:"Subscription",detail:"Free",chevron:false){upgrade=true}
                RowDivider();SettingRow(symbol:"sparkles",title:"Upgrade to ChatGPT Go",chevron:false){upgrade=true}
                RowDivider();SettingRow(symbol:"arrow.clockwise",title:"Restore purchases",chevron:false){store.notice("No purchases to restore")}
                RowDivider();SettingRow(symbol:"person.crop.circle",title:"Personalization"){page="Personalization"}
                RowDivider();SettingRow(symbol:"bell",title:"Notifications"){page="Notifications"}
                RowDivider();SettingRow(symbol:"square.grid.2x2",title:"Apps"){page="Apps"}
                RowDivider();SettingRow(symbol:"person.2",title:"Parental controls"){page="Parental controls"}
                RowDivider();SettingRow(symbol:"externaldrive",title:"Data controls"){page="Data controls"}
                RowDivider();SettingRow(symbol:"archivebox",title:"Archived chats"){page="Archived chats"}
                RowDivider();SettingRow(symbol:"shield",title:"Security"){page="Security"}
            }
            sectionLabel("App")
            GroupCard{
                SettingRow(symbol:"globe",title:"App language",detail:"English"){store.notice("English selected")}
                RowDivider();Menu{ForEach(["System","Dark","Light"],id:\.self){value in Button{store.state.appearance=value;store.save()}label:{if value==store.state.appearance{Label(value,systemImage:"checkmark")}else{Text(value)}}}}label:{menuRow("sun.max","Appearance",store.state.appearance)}.accessibilityLabel("Appearance")
                RowDivider();Menu{ForEach(["Default","Orange","Yellow","Green","Blue","Pink"],id:\.self){value in Button{store.state.accent=value;store.save()}label:{Label(value,systemImage:value==store.state.accent ? "checkmark":"circle.fill")}}}label:{menuRow("circle","Accent color",store.state.accent)}.accessibilityLabel("Accent color")
                RowDivider();toggle("Haptic feedback","iphone.radiowaves.left.and.right",$store.state.haptics)
                RowDivider();toggle("Correct spelling automatically","character.cursor.ibeam",$store.state.correctSpelling)
            }
            sectionLabel("Speech")
            GroupCard{SettingRow(symbol:"globe",title:"Main language",detail:"Auto-detect"){store.notice("Automatic language detection selected")}}
            sectionLabel("Voice")
            GroupCard{Menu{ForEach(["Arbor","Breeze","Cove","Juniper","Sol"],id:\.self){v in Button(v){store.state.voice=v;store.save()}}}label:{menuRow("waveform","Voice",store.state.voice)}}
            sectionLabel("About")
            GroupCard{SettingRow(symbol:"ladybug",title:"Report bug"){page="Report bug"};RowDivider();SettingRow(symbol:"questionmark.circle",title:"Help Center"){page="Help Center"};RowDivider();SettingRow(symbol:"doc",title:"Terms of Use"){page="Terms of Use"};RowDivider();SettingRow(symbol:"hand.raised",title:"Privacy Policy"){page="Privacy Policy"};RowDivider();VStack(alignment:.leading,spacing:4){Text("ChatGPT Demo for iOS");Text("Native Swift · Local services · 1.0").font(.system(size:13)).foregroundStyle(.secondary)}.frame(maxWidth:.infinity,alignment:.leading).padding(16)}
            GroupCard{SettingRow(symbol:"rectangle.portrait.and.arrow.right",title:"Log out",chevron:false){logout=true}}
        }
    }
    func sectionLabel(_ title:String)->some View{Text(title).font(.system(size:16)).foregroundStyle(.secondary).padding(.leading,16).padding(.bottom,-14)}
    func menuRow(_ icon:String,_ title:String,_ value:String)->some View{HStack(spacing:14){Image(systemName:icon).frame(width:22);Text(title);Spacer();Text(value).foregroundStyle(.secondary);Image(systemName:"chevron.up.chevron.down").font(.system(size:11)).foregroundStyle(.secondary)}.font(.system(size:17)).padding(.horizontal,16).frame(height:51).foregroundStyle(.primary)}
    func toggle(_ title:String,_ icon:String,_ binding:Binding<Bool>)->some View{Toggle(isOn:binding){Label(title,systemImage:icon)}.font(.system(size:17)).tint(.green).padding(.horizontal,16).frame(minHeight:51).onChange(of:binding.wrappedValue){_,_ in store.save()}}
    var personalization:some View{Group{
        GroupCard{Menu{ForEach(["Default","Professional","Friendly","Candid","Quirky","Efficient","Cynical"],id:\.self){v in Button(v){store.state.tone=v;store.save()}}}label:{menuRow("text.bubble","Base style and tone",store.state.tone)}}
        Text("This is the main style and tone ChatGPT uses in your conversations.").font(.system(size:13)).foregroundStyle(.secondary)
        sectionLabel("Custom instructions");TextField("Share anything else you’d like ChatGPT to know",text:$store.state.instructions,axis:.vertical).lineLimit(3...5).padding(16).background(pageColor,in:RoundedRectangle(cornerRadius:20))
        sectionLabel("Your nickname");TextField("Name",text:$store.state.nickname).padding(16).background(pageColor,in:Capsule())
        sectionLabel("Your occupation");TextField("Engineer, student, etc.",text:$store.state.occupation).padding(16).background(pageColor,in:Capsule())
        sectionLabel("Memory");GroupCard{toggle("Reference saved memories","brain",$store.state.memory);RowDivider();toggle("Reference chat history","clock",$store.state.history)}
        PrimaryButton(title:"Save"){store.save();page="Settings"}
    }}
    var dataControls:some View{Group{GroupCard{toggle("Improve the model for everyone","sparkles",$store.state.improveModel)};Text("This demo stores conversations on this device. No data is sent to an AI service.").font(.system(size:14)).foregroundStyle(.secondary);GroupCard{SettingRow(symbol:"archivebox",title:"Archive all chats",chevron:false){for c in store.state.conversations{store.archive(c.id)};store.notice("All chats archived")}}}}
    var notifications:some View{Group{Text("Notifications").font(.system(size:20,weight:.semibold));Text("Notification delivery is mocked in this demo.").foregroundStyle(.secondary)}}
    var security:some View{Group{sectionLabel("Multi-factor authentication (MFA)");GroupCard{SettingRow(symbol:"key",title:"Authenticator app",detail:"Off"){store.notice("Authentication is local in this demo")};RowDivider();SettingRow(symbol:"bell",title:"Push notifications",detail:"Off"){store.notice("Authentication is local in this demo")}}}}
    var archived:some View{VStack{let chats=store.state.conversations.filter(\.archived);if chats.isEmpty{Spacer();EmptyState(symbol:"archivebox",title:"No archived chats",subtitle:"Archived conversations will be available here.");Spacer()}else{ScrollView{VStack(alignment:.leading,spacing:10){Text("Today").font(.system(size:13)).foregroundStyle(.secondary);ForEach(chats){chat in Menu{Button("View"){store.open(chat);dismiss()};Button("Unarchive"){store.unarchive(chat.id)};Button("Delete",role:.destructive){store.deleteChat(chat.id)}}label:{Text(chat.title).foregroundStyle(.primary).frame(maxWidth:.infinity,alignment:.leading).padding(.vertical,18)}.accessibilityLabel(chat.title)}}.padding(24)}}}}
}
struct ProfileEditor:View{
    @EnvironmentObject var store:Store
    @Environment(\.dismiss) var dismiss
    @State var name=""
    @State var username=""
    var body:some View{VStack(spacing:16){Avatar(initials:store.initials,size:80).padding(.top,30);InputBox(title:"Name",text:$name);InputBox(title:"Username",text:$username);Text("Your profile helps people recognize you.").font(.system(size:13)).foregroundStyle(.secondary);PrimaryButton(title:"Save profile",enabled:!name.isEmpty){store.state.name=name;store.state.username=username;store.save();dismiss()};Button("Cancel"){dismiss()}.buttonStyle(.plain)}.padding(24).onAppear{name=store.state.name;username=store.state.username}.presentationCornerRadius(38)}
}
