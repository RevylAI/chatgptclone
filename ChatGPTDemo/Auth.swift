import SwiftUI
struct WelcomeView:View {
    @EnvironmentObject private var store:Store
    @State private var step = 0
    @State private var selected: Set<String> = ["Learn something"]
    private let ink = Color(red:21/255,green:21/255,blue:21/255)
    private let red = Color(red:231/255,green:45/255,blue:67/255)
    private let muted = Color(red:98/255,green:98/255,blue:98/255)
    private let interests = [
        ("Learn something", "Study buddies, minus the group chat", "book.closed"),
        ("Make something", "Stories, sketches, and bright ideas", "sparkle"),
        ("Build something", "Code, plans, and side projects", "chevron.left.forwardslash.chevron.right"),
        ("Figure life out", "A little clarity for the everyday", "asterisk")
    ]
    private var prompt: String {
        if selected.contains("Learn something") || selected.isEmpty { return "Explain a tricky idea like I’m new to it." }
        if selected.contains("Make something") { return "Help me turn a story idea into a first draft." }
        if selected.contains("Build something") { return "Help me break a side project into small steps." }
        return "Help me make a simple plan for my week."
    }
    var body: some View {
        VStack(spacing:0) {
            navigation
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment:.leading,spacing:0) {
                        Color.clear.frame(height:0).id("onboarding-top")
                        if step == 0 { welcome }
                        else if step == 1 { choices }
                        else { firstPrompt }
                    }.padding(.horizontal,24).padding(.bottom,8)
                }.scrollIndicators(.hidden)
                    .onChange(of:step) { _,_ in proxy.scrollTo("onboarding-top",anchor:.top) }
            }
            footer
        }
        .background(Color.white.ignoresSafeArea())
        .foregroundStyle(ink)
        .preferredColorScheme(.light)
        .onAppear { if let saved = store.state.onboardingInterests { selected = Set(saved) } }
    }
    private func display(_ size: CGFloat) -> Font {
        .custom("SpaceGrotesk-Light",size:size,relativeTo:.largeTitle).weight(.bold)
    }
    private func eyebrow(_ text:String) -> some View {
        Text(text).font(.system(size:12,weight:.bold)).tracking(1.1).foregroundStyle(red)
    }
    private var navigation: some View {
        HStack(spacing:9) {
            if step > 0 {
                Button { step -= 1 } label: {
                    Image(systemName:"chevron.left").font(.system(size:18,weight:.medium)).frame(width:24,height:44)
                }.accessibilityLabel("Back").accessibilityIdentifier("Onboarding back")
            }
            Text("ChatGPT").font(display(18))
            Spacer()
            if step < 2 {
                Button("Skip") {
                    if step == 0 { store.completeOnboarding(interests:[],prompt:nil) }
                    else { selected = []; step = 2 }
                }.font(.system(size:14,weight:.medium)).foregroundStyle(muted).frame(minWidth:44,minHeight:44)
                    .accessibilityIdentifier("Onboarding skip")
            } else {
                Text("03 / 03").font(.system(size:14)).foregroundStyle(muted)
            }
        }.buttonStyle(.plain).padding(.horizontal,24).frame(height:48)
    }
    private var welcome: some View {
        VStack(alignment:.leading,spacing:0) {
            ZStack(alignment:.topLeading) {
                Image("MangaSidekick").resizable().scaledToFit()
                GeometryReader { geometry in
                    Text("HEY, YOU!").font(display(14)).minimumScaleFactor(0.7).lineLimit(1)
                        .frame(width:geometry.size.width * 0.19,height:20)
                        .position(x:geometry.size.width * 0.80,y:geometry.size.height * 0.28)
                }
            }.aspectRatio(342/258,contentMode:.fit).padding(.top,15).accessibilityHidden(true)
            eyebrow("YOUR AI SIDEKICK. YOUR NEXT CHAPTER.").font(.system(size:11)).padding(.top,22)
            Text("YOUR NEXT ARC\nSTARTS HERE.").font(display(46)).tracking(-2.4).lineSpacing(-3)
                .fixedSize(horizontal:false,vertical:true).padding(.top,12).accessibilityAddTraits(.isHeader)
            Text("Dream it. Ask it. Figure it out.\nMeet ChatGPT, a little help for your big ideas.")
                .font(.system(size:16)).foregroundStyle(muted).lineSpacing(4).fixedSize(horizontal:false,vertical:true).padding(.top,12)
        }
    }
    private var choices: some View {
        VStack(alignment:.leading,spacing:0) {
            eyebrow("CHAPTER 01 / MAKE IT YOURS").padding(.top,35)
            Text("CHOOSE YOUR\nSIDE QUEST.").font(display(42)).tracking(-1.9).lineSpacing(-2)
                .fixedSize(horizontal:false,vertical:true).padding(.top,16).accessibilityAddTraits(.isHeader)
            Text("What would you like a little help with?").font(.system(size:16)).foregroundStyle(muted).padding(.top,16)
            VStack(spacing:12) {
                ForEach(interests,id:\.0) { title,subtitle,symbol in
                    Button {
                        if selected.contains(title) { selected.remove(title) } else { selected.insert(title) }
                    } label: {
                        HStack(spacing:14) {
                            Image(systemName:symbol).font(.system(size:21)).frame(width:24)
                            VStack(alignment:.leading,spacing:4) {
                                Text(title).font(.system(size:17,weight:.semibold))
                                Text(subtitle).font(.system(size:12)).opacity(0.8).fixedSize(horizontal:false,vertical:true)
                            }.frame(maxWidth:.infinity,alignment:.leading)
                            ZStack {
                                Rectangle().fill(selected.contains(title) ? red : Color.white)
                                Rectangle().strokeBorder(selected.contains(title) ? red : ink,lineWidth:1.5)
                                if selected.contains(title) { Image(systemName:"checkmark").font(.system(size:12,weight:.bold)).foregroundStyle(.white) }
                            }.frame(width:21,height:21)
                        }.padding(.horizontal,16).padding(.vertical,12).frame(maxWidth:.infinity,minHeight:64,alignment:.leading)
                            .foregroundStyle(selected.contains(title) ? Color.white : ink)
                            .background(selected.contains(title) ? ink : .white)
                            .overlay(Rectangle().strokeBorder(ink,lineWidth:2))
                            .background(ink.opacity(0.1).offset(x:3,y:3))
                    }.buttonStyle(.plain).accessibilityLabel(title).accessibilityValue(selected.contains(title) ? "Selected" : "Not selected")
                        .accessibilityAddTraits(selected.contains(title) ? [.isSelected] : [])
                        .accessibilityIdentifier("Interest: \(title)")
                }
            }.padding(.top,28).padding(.trailing,3)
        }
    }
    private var firstPrompt: some View {
        VStack(alignment:.leading,spacing:0) {
            eyebrow("CHAPTER 02 / THE FIRST SPARK").padding(.top,35)
            Text("EVERY BIG IDEA\nSTARTS SMALL.").font(display(44)).tracking(-2.2).lineSpacing(-2)
                .fixedSize(horizontal:false,vertical:true).padding(.top,16).accessibilityAddTraits(.isHeader)
            Text("You don’t need the perfect question.\nTry this one to get going.").font(.system(size:16)).foregroundStyle(muted).lineSpacing(4).padding(.top,16)
            VStack(alignment:.leading,spacing:18) {
                eyebrow("TRY ASKING")
                Text("“\(prompt)”").font(display(25)).tracking(-0.6).fixedSize(horizontal:false,vertical:true)
                HStack(spacing:10) {
                    Text("AI").font(.system(size:12,weight:.bold)).foregroundStyle(.white).frame(width:26,height:26).background(ink)
                    Text("A fresh perspective is one message away.").font(.system(size:14)).foregroundStyle(muted)
                }
            }.padding(20).frame(maxWidth:.infinity,minHeight:218,alignment:.topLeading)
                .background(Color.white).overlay(Rectangle().strokeBorder(ink,lineWidth:3))
                .background(ink.offset(x:5,y:5)).padding(.trailing,5).padding(.top,34)
                .accessibilityIdentifier("First prompt preview")
        }
    }
    private var footer: some View {
        VStack(alignment:.leading,spacing:0) {
            HStack(spacing:6) {
                ForEach(0..<3) { index in Rectangle().fill(index == step ? red : Color(white:0.91)).frame(width:32,height:4) }
            }.accessibilityElement(children:.ignore).accessibilityLabel("Step \(step+1) of 3").padding(.bottom,26)
            Button {
                if step < 2 { step += 1 }
                else { store.completeOnboarding(interests:interests.map(\.0).filter { selected.contains($0) },prompt:prompt) }
            } label: {
                HStack {
                    Text(["Let’s begin","Continue","Start chatting"][step]).font(display(17))
                    Spacer()
                    Image(systemName:"arrow.right").font(.system(size:20,weight:.medium))
                }.foregroundStyle(.white).padding(.horizontal,20).frame(height:56).background(red)
                    .overlay(Rectangle().strokeBorder(ink,lineWidth:2)).background(ink.offset(x:4,y:4))
            }.buttonStyle(.plain).accessibilityIdentifier("Onboarding primary action").padding(.trailing,4).padding(.bottom,14)
            Group {
                if step == 0 {
                    Text("By continuing, you agree to the [Terms](https://openai.com/policies/terms-of-use/)\nand acknowledge the [Privacy Policy](https://openai.com/policies/privacy-policy/).")
                } else if step == 1 { Text("Pick a few. There’s no wrong answer.") }
                else { Text("AI can make mistakes.\nCheck important information.") }
            }.font(.system(size:11)).foregroundStyle(muted).tint(muted).multilineTextAlignment(.center)
                .frame(maxWidth:.infinity,minHeight:32)
        }.padding(.horizontal,24).padding(.top,20)
    }
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
