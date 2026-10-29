import XCTest
@testable import ChatGPTDemo

final class OnboardingTests: XCTestCase {
    @MainActor func testCompletionPersistsInterestsAndQueuesAnEditablePrompt() throws {
        let suite = "Onboarding-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName:suite))
        defer { defaults.removePersistentDomain(forName:suite) }
        let options = LaunchOptions(environment:[:],arguments:[])
        let store = Store(defaults:defaults,options:options)
        store.completeOnboarding(interests:["Learn something","Build something"],prompt:"Explain a tricky idea like I’m new to it.")
        XCTAssertTrue(store.state.welcomed)
        XCTAssertFalse(store.state.signedIn)
        XCTAssertEqual(store.onboardingPrompt,"Explain a tricky idea like I’m new to it.")
        XCTAssertTrue(store.state.conversations.isEmpty)
        let restored = Store(defaults:defaults,options:options)
        XCTAssertTrue(restored.state.welcomed)
        XCTAssertEqual(restored.state.onboardingInterests,["Learn something","Build something"])
        XCTAssertTrue(restored.onboardingPrompt.isEmpty)
    }

    @MainActor func testSkipCompletesWithoutSendingOrQueuingAPrompt() throws {
        let suite = "Onboarding-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName:suite))
        defer { defaults.removePersistentDomain(forName:suite) }
        let store = Store(defaults:defaults,options:LaunchOptions(environment:[:],arguments:[]))
        store.completeOnboarding(interests:[],prompt:nil)
        XCTAssertTrue(store.state.welcomed)
        XCTAssertEqual(store.state.onboardingInterests,[])
        XCTAssertTrue(store.onboardingPrompt.isEmpty)
        XCTAssertTrue(store.state.conversations.isEmpty)
    }

    func testExistingStateWithoutInterestsStillDecodes() throws {
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with:JSONEncoder().encode(LocalState())) as? [String:Any])
        object.removeValue(forKey:"onboardingInterests")
        object["welcomed"] = true
        let decoded = try JSONDecoder().decode(LocalState.self,from:JSONSerialization.data(withJSONObject:object))
        XCTAssertTrue(decoded.welcomed)
        XCTAssertNil(decoded.onboardingInterests)
    }

    @MainActor func testExplicitOnboardingScreenOverridesDemoBypassWithoutDeletingChats() throws {
        let suite = "Onboarding-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName:suite))
        defer { defaults.removePersistentDomain(forName:suite) }
        let store = Store(defaults:defaults,options:LaunchOptions(environment:[:],arguments:[]))
        store.send("Keep this conversation")
        let replay = Store(defaults:defaults,options:LaunchOptions(environment:["DEMO_AUTH_BYPASS":"1","DEMO_SCREEN":"onboarding"],arguments:[]))
        XCTAssertFalse(replay.state.welcomed)
        XCTAssertTrue(replay.state.signedIn)
        XCTAssertEqual(replay.state.conversations.count,1)
    }
}
