import SwiftUI
struct WelcomeView:View {
    @EnvironmentObject var store:Store
    var body:some View {
        VStack(alignment:.leading,spacing:0) {
            Text("Welcome to ChatGPT").font(.system(size:32,weight:.bold)).minimumScaleFactor(0.8).lineLimit(1).padding(.top,54)
            Text("ChatGPT is a free AI assistant that can help you with a wide variety of tasks.").font(.system(size:17)).foregroundStyle(.secondary).padding(.top,23).padding(.bottom,40)
            info("flag","Responses can be inaccurate","ChatGPT may provide inaccurate information about people, places, or facts.")
            info("lock","Don’t share sensitive info","Chats may be reviewed and used for training. Learn more about your choices")
            info("gearshape.fill","Control your chat history","Decide whether new chats on this device will appear in your history and be used to improve our systems.")
            Spacer(minLength:20)
            PrimaryButton(title:"Continue"){store.state.welcomed=true;store.save()}
            Text("By continuing, you agree to our **Terms** and have read our **Privacy Policy**.").font(.system(size:15)).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.top,24).padding(.bottom,20)
        }.padding(.horizontal,24)
    }
    func info(_ icon:String,_ title:String,_ description:String)->some View {HStack(alignment:.top,spacing:22){Image(systemName:icon).font(.system(size:28)).frame(width:30);VStack(alignment:.leading,spacing:3){Text(title).font(.system(size:17,weight:.semibold));Text(description).font(.system(size:17)).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true)}}.padding(.bottom,28)}
}
struct AuthView:View {
    @EnvironmentObject var store:Store
    @Environment(\.dismiss) var dismiss
    @State var stage=0
    @State var email=""
    @State var password=""
    @State var code=""
    @State var fullName=""
    @State var age=""
    @State var signup=false
    @State var error=""
    @State var purpose="Personal tasks"
    var body:some View {
        VStack(spacing:0){
            if stage==0 {landing}
            else if stage>=5 {onboarding}
            else {
                SheetHeader(title:"",leading:stage>1 ? "chevron.left":nil,onLeading:{stage-=1}){dismiss()}
                Mark(size:42).padding(.top,2).padding(.bottom,18)
                Text(stage==1 ? "Log in or sign up":stage==2 ? (signup ? "Create your account":"Enter your password"):stage==3 ? "Check your inbox":"How old are you?").font(.system(size:20)).padding(.bottom,10)
                if stage==1 {Text("You’ll get smarter responses and can upload\nfiles, images and more.").font(.system(size:14)).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.bottom,30)}
                if stage==3 {Text("Enter the verification code we just sent to\n\(email). (Demo code: 123456)").font(.system(size:14)).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.bottom,24)}
                VStack(spacing:12){
                    if stage<=2 {InputBox(title:"Email",text:$email).keyboardType(.emailAddress)}
                    if stage==2 {InputBox(title:"Password",text:$password,secure:true)}
                    if stage==3 {InputBox(title:"Code",text:$code).keyboardType(.numberPad)}
                    if stage==4 {InputBox(title:"Full name",text:$fullName);InputBox(title:"Age",text:$age).keyboardType(.numberPad)}
                    if !error.isEmpty {Text(error).font(.system(size:13)).foregroundStyle(.red)}
                    PrimaryButton(title:"Continue",enabled:valid){next()}.padding(.top,12)
                    if stage==1 {
                        Text("OR").font(.system(size:12)).foregroundStyle(.secondary).padding(.vertical,8)
                        provider("Continue with Google",symbol:"g.circle")
                        provider("Continue with Apple",symbol:"apple.logo")
                        provider("Continue with phone",symbol:"phone")
                    }
                    if stage==2 {Button("Forgot password?"){stage=3}.buttonStyle(.plain).font(.system(size:14)).padding(.top,8)}
                    if stage==3 {Button("Resend email"){store.notice("Verification code: 123456")}.buttonStyle(.plain).font(.system(size:14)).padding(.top,8)}
                }.padding(.horizontal,24)
                Spacer()
                Text("Terms of Use  ·  Privacy Policy").underline().font(.system(size:12)).foregroundStyle(.secondary).padding(.bottom,30)
            }
        }.background(pageColor).presentationCornerRadius(38)
    }
    var valid:Bool {switch stage{case 1:return email.contains("@") && email.contains(".");case 2:return password.count>=8;case 3:return code.count==6;case 4:return !fullName.isEmpty && (Int(age) ?? 0)>=18;default:return true}}
    func next(){error="";if stage==3 && code != "123456" {error="Enter the demo verification code 123456.";return};if stage==3 && !signup{store.signIn(email:email);dismiss();return};if stage==4{store.signIn(email:email,name:fullName)};stage+=1}
    func provider(_ title:String,symbol:String)->some View {Button{email="alex@example.com";store.signIn(email:email);dismiss() }label:{Label(title,systemImage:symbol).font(.system(size:15,weight:.medium)).frame(maxWidth:.infinity).frame(height:42).overlay(Capsule().stroke(Color.primary.opacity(0.12)))}.buttonStyle(.plain)}
    var landing:some View {
        VStack {
            HStack{Spacer();RoundButton(symbol:"xmark",label:"Close"){dismiss()}}.padding(20)
            Spacer();Text("Let’s brainstorm●").font(.system(size:30,weight:.bold));Spacer();Spacer()
            VStack(spacing:12){
                Button{store.signIn(email:"alex@example.com");dismiss()}label:{Label("Continue with Apple",systemImage:"apple.logo").frame(maxWidth:.infinity).frame(height:46).background(.white,in:RoundedRectangle(cornerRadius:13)).foregroundStyle(.black)}
                Button{store.signIn(email:"alex@example.com");dismiss()}label:{Label("Continue with Google",systemImage:"g.circle.fill").frame(maxWidth:.infinity).frame(height:46).background(Color(white:0.18),in:RoundedRectangle(cornerRadius:13))}
                Button{signup=true;stage=1}label:{Text("Sign up").frame(maxWidth:.infinity).frame(height:46).background(Color(white:0.18),in:RoundedRectangle(cornerRadius:13))}
                Button{signup=false;stage=1}label:{Text("Log in").frame(maxWidth:.infinity).frame(height:46).overlay(RoundedRectangle(cornerRadius:13).stroke(Color(white:0.3)))}
            }.font(.system(size:17,weight:.medium)).foregroundStyle(.white).buttonStyle(.plain).padding(24).padding(.bottom,10).background(.black,in:UnevenRoundedRectangle(topLeadingRadius:38,topTrailingRadius:38))
        }.ignoresSafeArea(edges:.bottom)
    }
    var onboarding:some View {
        VStack(spacing:24){
            if stage==5 {
                Text("Stay in the loop").font(.system(size:25,weight:.semibold)).padding(.top,85)
                Text("Get an alert when ChatGPT completes a task,\nhas new suggestions, and more.").font(.system(size:15)).foregroundStyle(.secondary).multilineTextAlignment(.center)
                HStack{Mark();VStack(alignment:.leading){Text("ChatGPT").fontWeight(.semibold);Text("Your weekly news summary is ready.").font(.system(size:14)).foregroundStyle(.secondary)}}.padding(20).background(secondaryColor,in:RoundedRectangle(cornerRadius:24))
                Spacer();PrimaryButton(title:"Turn on notifications"){stage=6};Button("Maybe later"){stage=6}.buttonStyle(.plain)
            } else if stage==6 {
                Text("What do you want to use\nChatGPT for?").font(.system(size:25,weight:.semibold)).multilineTextAlignment(.center).padding(.top,70)
                Text("We’ll use this information to suggest ideas you\nmight find useful.").font(.system(size:14)).foregroundStyle(.secondary).multilineTextAlignment(.center)
                ForEach(["School","Work","Personal tasks","Fun & entertainment","Other"],id:\.self){p in Button{purpose=p}label:{HStack{Image(systemName:purpose==p ? "checkmark.circle.fill":"circle");Text(p);Spacer()}}.buttonStyle(.plain)}
                Spacer();PrimaryButton(title:"Continue"){stage=7}
            } else {
                Spacer();Text("Nice to meet you, \(store.state.name.split(separator:" ").first ?? "Alex").\nHere’s a quick tour...").font(.system(size:26,weight:.medium)).multilineTextAlignment(.center);Spacer()
                Text("Ask anything. Create images. Bring your files.").font(.system(size:17)).foregroundStyle(.secondary)
                PrimaryButton(title:"Done"){dismiss()}
            }
        }.padding(24).padding(.bottom,20)
    }
}
