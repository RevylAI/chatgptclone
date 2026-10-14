import SwiftUI

let pageColor = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? .black : .white })
let secondaryColor = Color(uiColor: .secondarySystemBackground)
let settingsColor = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? .black : UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1) })
let cardColor = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? UIColor(white: 0.11, alpha: 1) : .white })
func namedColor(_ name: String) -> Color {
    switch name {case "Blue":return .blue;case "Red":return .red;case "Orange":return .orange;case "Yellow":return .yellow;case "Green":return .green;case "Purple":return .purple;case "Pink":return .pink;default:return .primary}
}
struct RoundButton: View {
    let symbol: String
    let label: String
    var size: CGFloat = 44
    var floating = true
    let action: () -> Void
    var body: some View {
        Button(action:action) {AppGlyph(symbol:symbol).frame(width:size,height:size).contentShape(Rectangle()).background(floating ? pageColor : Color.clear,in:Circle()).shadow(color:.black.opacity(floating ? 0.04 : 0),radius:14,y:7)}
            .buttonStyle(.plain).accessibilityLabel(label).accessibilityIdentifier(label)
    }
}
struct AppGlyph: View {
    let symbol: String
    var body: some View {
        Group {
            if symbol == "line.3.horizontal.decrease" {
                VStack(alignment: .leading, spacing: 6) {
                    Capsule().frame(width: 20, height: 2)
                    Capsule().frame(width: 13, height: 2)
                }.frame(width: 24, height: 24)
            } else if symbol == "bubble.right.dashed" {
                TemporaryBubble().stroke(style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round, dash: [5, 4]))
                    .frame(width: 23, height: 23)
            } else if symbol == "person.badge.plus" {
                ZStack {
                    Image(systemName: "person").font(.system(size: 23, weight: .regular)).offset(x: -3)
                    Image(systemName: "plus").font(.system(size: 12, weight: .semibold))
                        .padding(2).background(pageColor).offset(x: 8, y: 8)
                }.frame(width: 26, height: 26)
            } else { Image(systemName: symbol).font(.system(size: 21, weight: .regular)) }
        }
    }
}
struct TemporaryBubble: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.width * 0.25, y: rect.height * 0.88))
        p.addCurve(to: CGPoint(x: rect.width * 0.5, y: 1), control1: CGPoint(x: -rect.width * 0.2, y: rect.height * 0.65), control2: CGPoint(x: 0, y: 1))
        p.addCurve(to: CGPoint(x: rect.width * 0.85, y: rect.height * 0.84), control1: CGPoint(x: rect.width * 1.08, y: 1), control2: CGPoint(x: rect.width * 1.1, y: rect.height * 0.65))
        p.addCurve(to: CGPoint(x: rect.width * 0.25, y: rect.height * 0.88), control1: CGPoint(x: rect.width * 0.68, y: rect.height * 1.02), control2: CGPoint(x: rect.width * 0.48, y: rect.height * 0.98))
        p.addLine(to: CGPoint(x: 1, y: rect.height))
        p.addLine(to: CGPoint(x: 3, y: rect.height * 0.75))
        return p
    }
}
struct PrimaryButton: View {
    let title: String
    var enabled = true
    let action: () -> Void
    var body: some View {Button(action:action){Text(title).font(.system(size:16,weight:.medium)).frame(maxWidth:.infinity).frame(height:50).foregroundStyle(pageColor)}.buttonStyle(.plain).disabled(!enabled).background(Color.primary.opacity(enabled ? 1:0.5),in:Capsule()).accessibilityIdentifier(title)}
}
struct SheetHeader: View {
    var title: String
    var leading: String? = nil
    var onLeading: (() -> Void)? = nil
    var done: String? = nil
    var close: () -> Void
    var body: some View {
        HStack {
            if let leading {RoundButton(symbol:leading,label:leading=="chevron.left" ? "Back":"Project settings",action:{onLeading?()})}else{Color.clear.frame(width:44,height:44)}
            Spacer();Text(title).font(.system(size:17,weight:.semibold));Spacer()
            if let done {Button(done,action:close).font(.system(size:15,weight:.semibold)).buttonStyle(.plain).frame(width:50,height:44)}else{RoundButton(symbol:"xmark",label:"Close",action:close)}
        }.padding(.horizontal,16).padding(.top,14).padding(.bottom,8)
    }
}
struct InputBox: View {
    let title: String
    @Binding var text: String
    var secure = false
    var body: some View {
        VStack(alignment:.leading,spacing:3){
            if !text.isEmpty {Text(title).font(.system(size:11)).foregroundStyle(.secondary)}
            if secure {SecureField(title,text:$text).textContentType(.password)}else{TextField(title,text:$text).autocorrectionDisabled().textInputAutocapitalization(.never)}
        }.font(.system(size:16)).padding(.horizontal,13).frame(height:56).background(pageColor,in:RoundedRectangle(cornerRadius:16)).overlay(RoundedRectangle(cornerRadius:16).stroke(Color.primary.opacity(0.12))).accessibilityIdentifier(title)
    }
}
struct Avatar: View {
    var initials = "AS"
    var size: CGFloat = 30
    var body: some View {Text(initials).font(.system(size:size*0.38,weight:.regular)).foregroundStyle(.white).frame(width:size,height:size).background(Color(red:0.08,green:0.72,blue:0.61),in:Circle())}
}
struct Mark: View {var size:CGFloat=36;var body:some View{Image("ChatMark").resizable().scaledToFit().frame(width:size,height:size)}}
struct SettingRow: View {
    var symbol: String
    var title: String
    var detail = ""
    var chevron = true
    var action: () -> Void
    var body: some View {Button(action:action){HStack(spacing:14){Image(systemName:symbol).frame(width:22);Text(title);Spacer(minLength:4);if !detail.isEmpty{Text(detail).foregroundStyle(.secondary)};if chevron{Image(systemName:"chevron.right").font(.system(size:14,weight:.semibold)).foregroundStyle(.tertiary)}}.font(.system(size:17)).padding(.horizontal,16).frame(minHeight:51).contentShape(Rectangle())}.buttonStyle(.plain)}
}
struct GroupCard<Content:View>:View { @ViewBuilder var content:Content;var body:some View{VStack(spacing:0){content}.background(cardColor,in:RoundedRectangle(cornerRadius:22))} }
struct RowDivider:View {var body:some View{Divider().padding(.leading,50).padding(.trailing,16)}}
struct EmptyState:View {let symbol:String;let title:String;let subtitle:String;var body:some View{VStack(spacing:8){Image(systemName:symbol).font(.system(size:28)).foregroundStyle(.tertiary);Text(title).font(.system(size:17,weight:.medium));Text(subtitle).font(.system(size:14)).foregroundStyle(.secondary).multilineTextAlignment(.center)}.padding(30)}}
