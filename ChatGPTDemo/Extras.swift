import SwiftUI
struct ToolsView:View {
    @Environment(\.dismiss) var dismiss
    var select:(String)->Void
    var body:some View {
        VStack(alignment:.leading,spacing:18){
            HStack{Text("ChatGPT").fontWeight(.semibold);Spacer();Button("Done"){dismiss()}}.padding(.top,22)
            HStack(spacing:12){ForEach([("camera","Camera"),("photo","Photos"),("doc","Files")],id:\.1){item in Button{select(item.1=="Files" ? "File":"Image");dismiss()}label:{VStack(spacing:9){Image(systemName:item.0).font(.system(size:25));Text(item.1).font(.system(size:14))}.frame(maxWidth:.infinity).frame(height:86).background(secondaryColor,in:RoundedRectangle(cornerRadius:18))}.buttonStyle(.plain)}}
            tool("photo","Create image","Visualize anything","Image")
            tool("sparkles","Thinking","Think longer for better answers","Think")
            tool("paperplane","Deep research","Get a detailed report","Research")
            tool("globe","Web search","Find real-time news and info","Search")
            tool("paperclip","Add files","Analyze or summarize","File")
            Spacer()
        }.padding(.horizontal,24).presentationDetents([.height(510)]).presentationDragIndicator(.visible).presentationCornerRadius(36)
    }
    func tool(_ icon:String,_ title:String,_ subtitle:String,_ mode:String)->some View{Button{select(mode);dismiss()}label:{HStack(spacing:16){Image(systemName:icon).font(.system(size:22)).frame(width:26);VStack(alignment:.leading,spacing:3){Text(title).font(.system(size:17,weight:.medium));Text(subtitle).font(.system(size:13)).foregroundStyle(.secondary)};Spacer()}.frame(height:46)}.buttonStyle(.plain)}
}
struct TemporaryInfo:View {
    @EnvironmentObject var store:Store
    @Environment(\.dismiss) var dismiss
    var body:some View{VStack(alignment:.leading,spacing:30){Text("Temporary Chat").font(.system(size:28,weight:.bold)).padding(.top,50);line("bubble.right.dashed","Not in history","Temporary chats won’t appear in your history.");line("sparkles","No model training","Temporary chats won’t be used to improve our models.");line("lock","Memory off","Custom instructions will still be followed.");Spacer();PrimaryButton(title:"Continue"){store.newChat();store.temporary=true;dismiss()}}.padding(26).padding(.bottom,20)}
    func line(_ icon:String,_ title:String,_ detail:String)->some View{HStack(alignment:.top,spacing:18){AppGlyph(symbol:icon);VStack(alignment:.leading,spacing:5){Text(title).fontWeight(.semibold);Text(detail).foregroundStyle(.secondary)}}}
}
struct VoiceView:View {
    @EnvironmentObject var store:Store
    @Environment(\.dismiss) var dismiss
    @State var stage=0
    @State var voice="Arbor"
    var body:some View {
        VStack(spacing:20){
            HStack{Button("Cancel"){dismiss()};Spacer();Text(stage==0 ? "":"Choose a voice").fontWeight(.semibold);Spacer();Color.clear.frame(width:45,height:44)}.padding(20)
            if stage==0 {
                Text("Say hello to Voice").font(.system(size:30,weight:.bold)).frame(maxWidth:.infinity,alignment:.leading).padding(.top,20)
                voiceLine("bubble.left.and.bubble.right","Natural conversations","Senses and responds to interruptions, humor, and more.")
                voiceLine("video","Live camera","Chat about your surroundings.")
                voiceLine("person.crop.circle","Personalized to you","Can use memory and custom instructions to shape responses.")
                voiceLine("lock","You’re in control","Audio is simulated locally in this demo.")
                Spacer();PrimaryButton(title:"Choose a voice"){stage=1}
            }else{
                Spacer();Circle().fill(.radialGradient(colors:[.white,Color.cyan.opacity(0.25),.cyan,.blue],center:.topLeading,startRadius:2,endRadius:170)).frame(width:stage==1 ? 160:210,height:stage==1 ? 160:210).blur(radius:0.4).shadow(color:.blue.opacity(0.09),radius:20)
                Text(stage==1 ? voice:"Hey there! What’s on your mind today?").font(.system(size:22,weight:.medium)).multilineTextAlignment(.center)
                if stage==1 {Text("Easygoing and versatile").foregroundStyle(.secondary);Picker("Voice",selection:$voice){ForEach(["Breeze","Arbor","Cove"],id:\.self){Text($0)}}.pickerStyle(.segmented).padding(.horizontal,30)}
                Spacer()
                PrimaryButton(title:stage==1 ? "Get started":"End voice chat"){if stage==1{store.state.voice=voice;store.save();stage=2}else{store.send("Hi! What is UI/UX?");dismiss()}}
            }
        }.padding(.horizontal,24).padding(.bottom,30).background(pageColor)
    }
    func voiceLine(_ icon:String,_ title:String,_ text:String)->some View{HStack(alignment:.top,spacing:16){Image(systemName:icon).font(.system(size:24)).frame(width:28);VStack(alignment:.leading,spacing:4){Text(title).font(.system(size:17,weight:.semibold));Text(text).font(.system(size:15)).foregroundStyle(.secondary)};Spacer()}}
}
struct GroupInfo:View {
    @EnvironmentObject var store:Store
    @Environment(\.dismiss) var dismiss
    var body:some View{VStack(spacing:18){SheetHeader(title:""){dismiss()};Spacer();Image(systemName:"person.2").font(.system(size:50));Text("Use ChatGPT together").font(.system(size:25,weight:.semibold));Text("Add people to your chats to plan, share ideas, and get creative.").foregroundStyle(.secondary).multilineTextAlignment(.center);PrimaryButton(title:"Start group chat"){store.newChat();store.send("Start a group chat");if let id=store.selectedChat{store.renameChat(id,"New group chat")};dismiss()};Spacer();Text("Group members and invitations are simulated locally.").font(.system(size:13)).foregroundStyle(.secondary)}.padding(24).presentationDetents([.medium])}
}
struct UpgradeView:View {
    @Environment(\.dismiss) var dismiss
    @State var plan="Go"
    @State var done=false
    var body:some View{VStack(spacing:22){SheetHeader(title:""){dismiss()};Image(systemName:"sparkles").font(.system(size:40)).foregroundStyle(.purple);Text("Get ChatGPT \(plan)").font(.system(size:30,weight:.bold));Text("Keep chatting with expanded access").foregroundStyle(.secondary);Picker("Plan",selection:$plan){Text("Go").tag("Go");Text("Plus").tag("Plus")}.pickerStyle(.segmented);ForEach(["Basic models","More messages","More uploads","More image creation","Longer memory"],id:\.self){feature in HStack{Text(feature);Spacer();Image(systemName:"checkmark").foregroundStyle(.purple)}.padding(.vertical,7)};Spacer();PrimaryButton(title:done ? "Demo plan selected":"Preview \(plan) plan"){done=true};Text("Local demo. No purchase or charge.").font(.system(size:13)).foregroundStyle(.secondary)}.padding(24)}
}
struct ImagesView:View {
    @EnvironmentObject var store:Store
    @Binding var modal:String?
    @State var preview=false
    var body:some View{VStack(alignment:.leading,spacing:25){HStack{RoundButton(symbol:"line.3.horizontal.decrease",label:"Open sidebar"){store.sidebar=true};Spacer();Text("Images").fontWeight(.semibold);Spacer();Color.clear.frame(width:44)};Text("Create an image").font(.system(size:20,weight:.semibold));ScrollView(.horizontal,showsIndicators:false){HStack{ForEach(["Animal infographic","Illustrated recipe","Studio headshot","Blueprint poster"],id:\.self){s in Button{store.newChat();NotificationCenter.default.post(name:.demoMode,object:"Image")}label:{VStack{RoundedRectangle(cornerRadius:20).fill(LinearGradient(colors:[.blue.opacity(0.5),.purple.opacity(0.2)],startPoint:.topLeading,endPoint:.bottomTrailing)).overlay(Image(systemName:"sparkles").font(.system(size:30))).frame(width:110,height:145);Text(s).font(.system(size:13)).frame(width:110)}}.buttonStyle(.plain)}}};Text("My images").font(.system(size:20,weight:.semibold));if store.state.conversations.flatMap(\.messages).contains(where:{$0.image != nil}){LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())]){ForEach(0..<4){_ in Button{preview=true}label:{Image("Coffee").resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius:20))}}}}else{Spacer();EmptyState(symbol:"photo",title:"Your images will appear here",subtitle:"Create an image from a chat to get started.").frame(maxWidth:.infinity)};Spacer();PrimaryButton(title:"Create an image"){store.newChat();modal="tools"}}.padding(.horizontal,16).sheet(isPresented:$preview){VStack{SheetHeader(title:"Image"){preview=false};Spacer();Image("Coffee").resizable().scaledToFit();Spacer()}}}
}
