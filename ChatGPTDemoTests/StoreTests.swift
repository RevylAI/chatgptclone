import XCTest
@testable import ChatGPTDemo
final class StoreTests:XCTestCase {
    @MainActor func isolated() -> (Store,UserDefaults,String) {
        let suite="DemoTest-"+UUID().uuidString
        let defaults=UserDefaults(suiteName:suite)!
        return (Store(defaults:defaults,options:LaunchOptions(environment:[:],arguments:[])),defaults,suite)
    }
    @MainActor func testDefaultIsGuestAndBypassRequiresExplicitFlag(){
        let (store,defaults,suite)=isolated();defer{defaults.removePersistentDomain(forName:suite)}
        XCTAssertFalse(store.state.signedIn)
        let bypass=Store(defaults:defaults,options:LaunchOptions(environment:["DEMO_AUTH_BYPASS":"1"],arguments:[]))
        XCTAssertTrue(bypass.state.signedIn);XCTAssertTrue(bypass.state.welcomed)
    }
    @MainActor func testStateSurvivesRelaunchAndLogout(){
        let (store,defaults,suite)=isolated();defer{defaults.removePersistentDomain(forName:suite)}
        store.signIn(email:"test@example.com");store.send("Help me create a cafe mocha recipe")
        let again=Store(defaults:defaults,options:LaunchOptions(environment:[:],arguments:[]))
        XCTAssertTrue(again.state.signedIn);XCTAssertEqual(again.state.conversations.count,1)
        XCTAssertEqual(again.state.conversations[0].messages.count,2)
        again.signOut()
        XCTAssertFalse(Store(defaults:defaults,options:LaunchOptions(environment:[:],arguments:[])).state.signedIn)
    }
    @MainActor func testTemporaryChatNeverPersists(){
        let (store,defaults,suite)=isolated();defer{defaults.removePersistentDomain(forName:suite)}
        store.temporary=true;store.send("Private draft")
        XCTAssertEqual(store.temporaryMessages.count,2);XCTAssertTrue(store.state.conversations.isEmpty)
        XCTAssertTrue(Store(defaults:defaults,options:LaunchOptions(environment:[:],arguments:[])).messages.isEmpty)
    }
    @MainActor func testProjectArchiveAndUnarchive(){
        let (store,defaults,suite)=isolated();defer{defaults.removePersistentDomain(forName:suite)}
        store.addProject(name:"UI UX",symbol:"folder",color:"Blue");let projectID=store.selectedProject
        store.send("Explain design");let id=store.selectedChat!
        XCTAssertEqual(store.currentChat?.projectID,projectID)
        store.archive(id);XCTAssertTrue(store.state.conversations[0].archived)
        store.unarchive(id);XCTAssertFalse(store.state.conversations[0].archived)
        store.deleteProject(projectID!);XCTAssertNil(store.state.conversations[0].projectID)
    }
    @MainActor func testResetTokenOnlyResetsOnce(){
        let (_,defaults,suite)=isolated();defer{defaults.removePersistentDomain(forName:suite)}
        let options=LaunchOptions(environment:["DEMO_RESET_TOKEN":"run-1"],arguments:[])
        let first=Store(defaults:defaults,options:options);first.send("Keep me")
        XCTAssertEqual(Store(defaults:defaults,options:options).state.conversations.count,1)
        XCTAssertTrue(Store(defaults:defaults,options:LaunchOptions(environment:["DEMO_RESET_TOKEN":"run-2"],arguments:[])).state.conversations.isEmpty)
    }
    @MainActor func testSourceContentsSurviveEditingAndRelaunch() {
        let (store, defaults, suite) = isolated()
        defer { defaults.removePersistentDomain(forName: suite) }
        store.addProject(name: "Design", symbol: "folder", color: "Blue")
        let projectID = store.selectedProject
        XCTAssertEqual(store.saveSource(title: "Notes", text: "First"), "Notes.txt")
        XCTAssertEqual(store.saveSource(title: "Notes", text: "Second"), "Notes (2).txt")
        XCTAssertEqual(store.saveSource(title: "Notes", text: "Edited", replacing: "Notes.txt"), "Notes.txt")
        let restored = Store(defaults: defaults, options: LaunchOptions(environment: [:], arguments: []))
        restored.selectedProject = projectID
        XCTAssertEqual(restored.project?.sourceContents?["Notes.txt"], "Edited")
        restored.removeSource("Notes.txt")
        XCTAssertNil(restored.project?.sourceContents?["Notes.txt"])
        XCTAssertEqual(restored.project?.sources, ["Notes (2).txt"])
    }
    func testLaunchArgumentsSupported(){
        let options=LaunchOptions(environment:[:],arguments:["App","-DEMO_AUTH_BYPASS","1","-DEMO_SEED_DATA","true"])
        XCTAssertTrue(options.bypass);XCTAssertTrue(options.seed)
    }
}
