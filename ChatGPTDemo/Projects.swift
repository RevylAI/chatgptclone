import SwiftUI
struct ProjectEditor:View {
    @EnvironmentObject var store:Store
    @Environment(\.dismiss) var dismiss
    var existing:Project? = nil
    @State var name=""
    @State var symbol="folder"
    @State var color="Blue"
    @State var icons=false
    var body:some View {
        VStack(spacing:20){
            SheetHeader(title:existing==nil ? "New project":"Edit project",leading:"gearshape",onLeading:{icons=true}){dismiss()}.padding(.bottom,-16)
            if existing==nil {Text("Projects give ChatGPT shared context across\nchats and files, all in one place.").font(.system(size:14)).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.bottom,8)}
            HStack(spacing:14){Button{icons=true}label:{Image(systemName:symbol).font(.system(size:23)).foregroundStyle(namedColor(color))}.accessibilityLabel("Choose icon");TextField("Project Name",text:$name).font(.system(size:17)).accessibilityIdentifier("Project Name")}.padding(12).background(Color(uiColor:.systemGray6),in:RoundedRectangle(cornerRadius:14)).padding(.horizontal,20)
            if existing==nil {HStack(spacing:7){chip("Investing","dollarsign.circle","Green");chip("Homework","graduationcap","Blue");chip("Writing","pencil.tip.crop.circle","Purple")}.frame(maxWidth:.infinity,alignment:.leading).padding(.horizontal,20)}
            Spacer()
            PrimaryButton(title:existing==nil ? "Create project":"Save",enabled:!name.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty){
                if var p=existing{p.name=name;p.symbol=symbol;p.color=color;store.updateProject(p)}else{store.addProject(name:name,symbol:symbol,color:color)};dismiss()
            }.padding(20).padding(.bottom,-4)
        }.background(pageColor).presentationCornerRadius(38).onAppear{if let p=existing{name=p.name;symbol=p.symbol;color=p.color}}
            .sheet(isPresented:$icons){iconPicker}
    }
    func chip(_ title:String,_ icon:String,_ c:String)->some View{Button{name=title;symbol=icon;color=c}label:{HStack(spacing:5){Image(systemName:icon).foregroundStyle(namedColor(c));Text(title)}.font(.system(size:17)).padding(.horizontal,11).padding(.vertical,10).overlay(Capsule().stroke(Color.primary.opacity(0.12)))}.buttonStyle(.plain)}
    var iconPicker:some View {
        VStack(spacing:28){SheetHeader(title:"Choose icon",done:"Done"){icons=false};Image(systemName:symbol).font(.system(size:45)).foregroundStyle(namedColor(color));HStack{ForEach(["Default","Red","Orange","Yellow","Green","Blue","Purple"],id:\.self){c in Button{color=c}label:{Circle().fill(namedColor(c)).frame(width:32,height:32).overlay(Circle().stroke(Color.primary,lineWidth:c==color ? 2:0).padding(-4))}.accessibilityLabel(c)}};LazyVGrid(columns:Array(repeating:GridItem(.flexible()),count:6),spacing:25){ForEach(["folder","dollarsign.circle","book","graduationcap","pencil","pencil.tip.crop.circle","curlybraces","terminal","music.note","popcorn","paintpalette","leaf","heart","bag","chart.bar","globe","dumbbell","airplane","gamecontroller","flask","cup.and.saucer","star","camera","lightbulb"],id:\.self){i in Button{symbol=i}label:{Image(systemName:i).font(.system(size:24)).frame(width:35,height:35)}.buttonStyle(.plain).accessibilityLabel(i)}}.padding(.horizontal,24);Spacer()}.background(pageColor).presentationCornerRadius(38)
    }
}
struct ProjectInstructions:View {
    @EnvironmentObject var store:Store
    @Environment(\.dismiss) var dismiss
    @State var text=""
    var body:some View {VStack(spacing:10){SheetHeader(title:"Instructions"){dismiss()};Text("Ask ChatGPT to focus on a topic, or use a specific style for responses in this project.").font(.system(size:16)).foregroundStyle(.secondary).padding(.horizontal,24);TextEditor(text:$text).font(.system(size:17)).padding(.horizontal,20).accessibilityLabel("Project instructions");PrimaryButton(title:"Save"){if var p=store.project{p.instructions=text;store.updateProject(p)};dismiss()}.padding(24)}.onAppear{text=store.project?.instructions ?? ""}.presentationCornerRadius(38)}
}
struct SourceEditor: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    var existing: String? = nil
    @State var title = ""
    @State var text = ""
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") { dismiss() }
                    .frame(width: 84, height: 44).background(pageColor, in: Capsule())
                Spacer()
                Text(existing == nil ? "Add text" : "Edit text").font(.headline)
                Spacer()
                Button("Save") {
                    if store.saveSource(title: title, text: text, replacing: existing) != nil { dismiss() }
                }.frame(width: 70, height: 44).background(pageColor, in: Capsule())
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }.buttonStyle(.plain).padding(.top, 24)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Title (optional)").foregroundStyle(.secondary).padding(.horizontal, 16)
                    TextField("e.g. Meeting notes", text: $title)
                        .padding(.horizontal, 16).frame(height: 50).background(pageColor, in: Capsule())
                        .accessibilityLabel("Source title").padding(.top, 10)
                    Text("Text").foregroundStyle(.secondary).padding(.horizontal, 16).padding(.top, 28)
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $text).padding(10).scrollContentBackground(.hidden)
                            .accessibilityLabel("Source text")
                        if text.isEmpty {
                            Text("Paste or type your text here").foregroundStyle(.tertiary)
                                .padding(.horizontal, 16).padding(.top, 25).allowsHitTesting(false)
                        }
                    }.frame(height: 270).background(pageColor, in: RoundedRectangle(cornerRadius: 26))
                        .clipShape(RoundedRectangle(cornerRadius: 26)).padding(.top, 10)
                }.padding(.top, 50)
            }.scrollDismissesKeyboard(.interactively)
        }.padding(.horizontal, 16).background(settingsColor)
            .presentationCornerRadius(38)
            .onAppear {
                if let existing {
                    title = existing.hasSuffix(".txt") ? String(existing.dropLast(4)) : existing
                    text = store.project?.sourceContents?[existing] ?? ""
                }
            }
    }
}
