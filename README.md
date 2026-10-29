# ChatGPT Swift Demo · Revyl

A native SwiftUI demo built and verified on cloud iPhones with [Revyl](https://revyl.ai). Chat, auth, images, and voice are mocked locally—no backend or API key required.

![Home, project notes, and dark mode](evidence/showcase.jpg)

## Run

Open `ChatGPTDemo.xcodeproj` in Xcode and run the `ChatGPTDemo` scheme on an iPhone simulator (iOS 17+).

For instant access, set these launch environment variables:

```text
DEMO_AUTH_BYPASS=1
DEMO_SEED_DATA=1
```

Optional: change `DEMO_RESET_TOKEN` to reset local data. For manual login, use any demo email, an 8+ character password, and code `123456`.

First launch uses the three-step Manga Club onboarding: welcome, optional interests, and a suggested first prompt. Completing it saves the interests and opens chat with an editable draft; it never sends automatically. Skip on the welcome screen goes straight to an empty chat. Set `DEMO_SCREEN=onboarding` to replay the flow without deleting existing chats, including when auth bypass is enabled; remove that override to test normal relaunch persistence.

The selected [Paper direction A](https://app.paper.design/file/01M64RXA97W2EZETN4BX62X8Y3/p-1-0) is saved in Revyl’s Files library as `895213b0-bc6a-4eb6-aa8f-e2ce3750aeb1`; behavior and verification context is `a9e3f872-6776-44de-a53b-5198471d5dc1`. The bundled Space Grotesk font is licensed under the SIL Open Font License in `ChatGPTDemo/SpaceGrotesk-OFL.txt`.

## Revyl

Cloud builds and GitHub PR review are configured in [`.revyl/config.yaml`](.revyl/config.yaml). Proof of changes is enabled. Previews and proof sessions attach `DEMO_AUTH_BYPASS=1` and `DEMO_SEED_DATA=1` from Revyl launch variables; no pre-script is needed for local mock auth. Forks need their own Revyl project, launch variables, and GitHub connection.

[Verification notes](evidence/verification.md) · [Design reference](https://mobbin.com/apps/chat-gpt-ios-a96b7f4c-6bfa-4c9d-a6b7-562160feb391/a0b14f48-3d1c-4286-828b-e95ad04fef10/screens)

Independent demo, not affiliated with OpenAI. Full UI parity is still in progress.
