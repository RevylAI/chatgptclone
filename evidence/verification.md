# Direct cloud verification — 2026-10-14

## Method and build

Used Revyl CLI device commands to interact with the app, capture screenshots, and inspect observed behavior. No persisted tests were created or run after the user requested direct device interaction. The earlier test run `011e4ae0-1b80-4ffc-94a8-3984957d6847` was cancelled; its device reached `cancelled`. It is not a passed suite.

- App: ChatGPT Swift Demo 20261014 (`3c0e0458-75a0-4a38-bd4c-152d25d756cb`)
- Bundle: `ai.revyl.demo.chatgpt`
- Final successful remote build: `87ba8aa6-f874-4b12-8a2c-aa224061de0d`
- Artifact: `3e2cf5ab-2dca-4c50-837b-91a420bb5a74` (`remote-87ba8aa6`)
- Local simulator build also succeeded; log: `work/local-build-direct.log`.
- Direct device session: `8be39170-9f5c-452b-8a80-0eea4545cc8f`, iPhone 16 / iOS 26.2. Shutdown was requested and `device info` confirmed terminal state `completed`.
- Launch environment: `DEMO_AUTH_BYPASS=1`, `DEMO_SEED_DATA=1`, `DEMO_RESET_TOKEN=direct-20261014-final`.
- Current source hashes: `evidence/final-source-manifest.json`.

## Observed flows

| Flow | Observation and evidence |
| --- | --- |
| Local authentication bypass | Opened signed-in home without login using launch variables. `direct-home.png`. This is a mock local session, not a bypass of a remote service. |
| Project creation | Created Design Lab and opened it. `direct-project.png`; corrected title/toolbar in `final-project.png`. |
| Text source | Saved Design Notes.txt with “Make the interface clear and accessible”, reopened the saved contents. `direct-source-reopened.png`. |
| Persistence and first-open note fix | On artifact `ba15af61-a321-43ee-abb2-1bd348196b75`, Design Lab and Design Notes.txt survived relaunch; the first opening correctly showed Edit text with the saved title and complete contents. `final-source.png`. |
| Archive and restore | Archived Cafe Mocha Recipe, observed it in Archived Chats, restored it, and observed it in the sidebar. `direct-archive.png`, `direct-restored-sidebar.png`. |
| Temporary chat | On artifact `ba15af61-a321-43ee-abb2-1bd348196b75`, opened onboarding, sent “Secret temporary note”, saw its reply, and confirmed the sidebar contained only the three ordinary conversations. `direct-temporary-info.png`, `direct-temporary-chat.png`, `direct-temporary-history.png`. |
| Live appearance change | On the final artifact, switched Light → Dark without closing Settings. The open sheet updated correctly with black background and distinct dark cards. `final-dark.png`. |
| Simulated voice | Chose a voice, started and ended the mock session, and saw its UI/UX conversation in chat. `direct-voice-result.png`. No real audio service was used. |

The final artifact differs from `ba15af61-a321-43ee-abb2-1bd348196b75` only by applying the selected appearance to the Settings sheet. The note and temporary-chat fixes were verified on that preceding artifact; the appearance fix was verified on the final artifact. Earlier main-flow observations used intermediate builds, as shown by their screenshots.

## Corrections made from cloud observations

Adjusted home composer/header spacing, sidebar controls, project form spacing, toolbar/menu tint, project title color, dark card colors, and source editor layout. Fixed missing dashed-bubble artwork and its tap area. Changed source sheet presentation to carry the selected filename, fixing an empty Add text sheet on first opening a saved note after launch. Constrained the voice header spacer so it no longer expands vertically (`final-voice.png`). Applied the selected appearance directly to the Settings sheet so its open presentation updates when the choice changes. Source contents persist locally, and chat/project sharing uses the native share sheet.

## Scope and limits

All 384 Mobbin reference screens are available locally under `references/screens/`. Visual review covered selected main-flow screens, not every state in that collection. Full 100% UI parity has not been achieved or verified. Temporary-chat onboarding, voice, generated images, collaboration, subscriptions, and several secondary settings use simplified local mock behavior. System status bars and presentation chrome can also differ from the captured reference OS.

Eight model checks passed earlier in the session, before the direct-device-only request (`model-checks.txt`). They were not rerun and are not evidence of a completed cloud test suite. Historical test definitions remain in `.revyl/tests/`; this workflow does not run them.

These observations were captured before public repository publication. The original workspace was retained during migration.


## Automatic session authentication

Created organization launch variables `DEMO_AUTH_BYPASS=1` and `DEMO_SEED_DATA=1`, and attached their names under `session.auth_bypass.launch_vars` in `.revyl/config.yaml`. The app already reads these as environment values or iOS `-KEY value` argument pairs. No app code or build change was needed.

Started fresh session `3e981afd-24f8-4d29-9e00-6e7f21a851c0` on artifact `3e2cf5ab-2dca-4c50-837b-91a420bb5a74` using the repo configuration, with no explicit launch variables and `--no-inherited-launch-vars`. Inspected `auth-config-home.png` and `auth-config-sidebar.png`: the app skipped onboarding/login, displayed the signed-in avatar, and showed both sample projects and conversations. No persisted tests or proof-of-changes runs were triggered.

Revyl's [session preparation documentation](https://docs.revyl.com/cli/device/auth-and-session-prep) distinguishes the paths: CLI/proof agents can run `session.before_script`; GitHub preview links have no checkout and use stored organization launch variables. This demo uses static, non-secret mock-auth flags, so it needs neither a before script nor a deep link. The committed configuration supplies the shared launch-variable references for new preview/proof sessions; a full GitHub PR preview/proof run has not been exercised here. Existing sessions must be restarted to receive changed launch configuration.

The verification device was stopped; `device info` confirmed terminal state `completed`.
