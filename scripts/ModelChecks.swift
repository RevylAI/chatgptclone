import Foundation
@main struct ModelChecks {
    @MainActor static func main() {
        let suite="ChatGPTDemo-Checks-"+UUID().uuidString
        let defaults=UserDefaults(suiteName:suite)!
        defer{defaults.removePersistentDomain(forName:suite)}
        let clean=LaunchOptions(environment:[:],arguments:[])
        let s=Store(defaults:defaults,options:clean)
        precondition(!s.state.signedIn && !s.state.welcomed)
        let bypass=Store(defaults:defaults,options:LaunchOptions(environment:["DEMO_AUTH_BYPASS":"1"],arguments:[]))
        precondition(bypass.state.signedIn && bypass.state.welcomed)
        print("PASS explicit launch-variable bypass and default guest")
        bypass.signIn(email:"demo@example.com");bypass.send("Cafe mocha recipe")
        let again=Store(defaults:defaults,options:clean)
        precondition(again.state.signedIn && again.state.conversations.count==1 && again.state.conversations[0].messages.count==2)
        again.signOut();precondition(!Store(defaults:defaults,options:clean).state.signedIn)
        print("PASS local authentication and chat persistence across relaunch")
        let before=again.state.conversations.count
        again.temporary=true;again.send("Secret temporary note")
        precondition(again.state.conversations.count==before && again.temporaryMessages.count==2)
        precondition(Store(defaults:defaults,options:clean).temporaryMessages.isEmpty)
        print("PASS temporary chat excluded from durable state")
        again.newChat();again.addProject(name:"Design",symbol:"folder",color:"Blue")
        let p=again.selectedProject!;again.send("Explain UI UX");let c=again.selectedChat!
        precondition(again.currentChat?.projectID==p)
        again.archive(c);precondition(again.state.conversations.first{$0.id==c}!.archived)
        again.unarchive(c);precondition(!again.state.conversations.first{$0.id==c}!.archived)
        again.deleteProject(p);precondition(again.state.conversations.first{$0.id==c}!.projectID==nil)
        print("PASS project association, archive, restore and project deletion")
        again.addProject(name:"Sources",symbol:"folder",color:"Blue")
        let sourceProject=again.selectedProject!
        precondition(again.saveSource(title:"Notes",text:"Original content")=="Notes.txt")
        precondition(again.saveSource(title:"Notes",text:"Second content")=="Notes (2).txt")
        precondition(again.saveSource(title:"Renamed",text:"Updated content",replacing:"Notes.txt")=="Renamed.txt")
        let restored=Store(defaults:defaults,options:clean)
        restored.selectedProject=sourceProject
        precondition(restored.project?.sourceContents?["Renamed.txt"]=="Updated content")
        precondition(restored.project?.sources.count==2)
        precondition(restored.project?.sourceContents?["Notes.txt"]==nil)
        precondition(restored.saveSource(title:"Empty",text:"  ")==nil)
        restored.removeSource("Renamed.txt")
        let deleted=Store(defaults:defaults,options:clean)
        deleted.selectedProject=sourceProject
        precondition(deleted.project?.sourceContents?["Renamed.txt"]==nil)
        precondition(deleted.project?.sources==["Notes (2).txt"])
        print("PASS source contents persist, duplicate titles, editing and deletion")
        let oldJSON=try! JSONSerialization.jsonObject(with:JSONEncoder().encode(restored.state)) as! [String:Any]
        var legacy=oldJSON
        legacy["projects"]=(oldJSON["projects"] as! [[String:Any]]).map { item in var p=item;p.removeValue(forKey:"sourceContents");return p }
        let legacyData=try! JSONSerialization.data(withJSONObject:legacy)
        let decoded=try! JSONDecoder().decode(LocalState.self,from:legacyData)
        precondition(decoded.projects.count==restored.state.projects.count)
        print("PASS existing project state migrates without losing data")
        let opts=LaunchOptions(environment:["DEMO_RESET_TOKEN":"token-a"],arguments:[])
        let reset=Store(defaults:defaults,options:opts);precondition(reset.state.conversations.isEmpty);reset.send("Keep me")
        precondition(Store(defaults:defaults,options:opts).state.conversations.count==1)
        precondition(Store(defaults:defaults,options:LaunchOptions(environment:["DEMO_RESET_TOKEN":"token-b"],arguments:[])).state.conversations.isEmpty)
        print("PASS reset token is idempotent across relaunch")
        precondition(LaunchOptions(environment:[:],arguments:["App","-DEMO_AUTH_BYPASS","1"]).bypass)
        print("PASS launch argument fallback")
    }
}
