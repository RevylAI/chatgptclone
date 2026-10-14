# ChatGPT Swift Demo · Built with Revyl

A native SwiftUI showcase of building and refining a mobile app with [Revyl](https://revyl.ai): cloud builds, a cloud iPhone, direct CLI interaction, screenshots, and an iterative UI development loop. Authentication, chat replies, image generation, and voice interaction use local fixtures. No backend or OpenAI API key is required.

![App home, saved project note, and dark appearance](evidence/showcase.jpg)

The implementation is inspired by the June 2026 ChatGPT iOS screens on Mobbin. This is an independent demonstration, not an official OpenAI app. ChatGPT and OpenAI marks belong to their respective owners.

## What this showcases

- Build a native iOS app remotely and install the exact returned build on a cloud device.
- Skip local demo authentication through launch variables, with reproducible seed/reset behavior.
- Drive the app through `revyl device` commands and inspect actual screenshots.
- Find and fix UI issues in the loop: source-sheet state, button hit areas, modal spacing, and live dark-mode updates.
- Verify project persistence, archive/restore, temporary history exclusion, and simulated voice through direct interaction.

See [verification notes](evidence/verification.md) for the build identities, observed behavior, and remaining parity gaps.

## Open and build

Open `ChatGPTDemo.xcodeproj` in Xcode and run the `ChatGPTDemo` scheme on an iPhone simulator. The project supports iOS 17 and later.

```sh
xcodebuild -project ChatGPTDemo.xcodeproj -scheme ChatGPTDemo \
  -configuration Debug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath build
```

`project.yml` is the XcodeGen source. Regenerate the checked-in project with `xcodegen generate` if its target configuration changes.

## Local authentication and launch variables

Without launch variables, a fresh installation opens onboarding and guest chat. Use Sign up → Log in, any demo email, a password of at least eight characters, and verification code `123456`. For example: `demo@example.com` / `demo123456`.

Set these environment variables in the Xcode scheme or Revyl launch configuration:

| Variable | Value | Behavior |
| --- | --- | --- |
| `DEMO_AUTH_BYPASS` | `1` | Starts with a local signed-in session and skips onboarding. |
| `DEMO_SEED_DATA` | `1` | Adds sample projects and conversations when the store is empty. |
| `DEMO_RESET_TOKEN` | Any unique string | Clears local state once per new token. Reusing it preserves state across relaunches. |
| `DEMO_SCREEN` | `sidebar`, `recipe`, `project`, `settings` | Opens a specific demonstration screen. Seed data is needed for recipe/project. |

Equivalent launch arguments, such as `-DEMO_AUTH_BYPASS 1`, are supported. Environment values take precedence. These switches are guarded by the `DEMO_MODE` compilation condition, enabled in this demo project's configurations. This is a local mock session, not a bypass of a real authentication service. Signing out clears the stored session; launching again with the bypass flag signs in again.

## Implemented flows

- Welcome, local login/signup, verification, logout, and saved session.
- Chat composition and fixture replies; rename, archive, restore, delete, search, and native sharing.
- Temporary chat excluded from saved history.
- Projects, icons/colors, instructions, chat association, and text sources with persistent contents, editing, and removal.
- Profile, appearance, and personalization settings.
- Simulated voice, image, group, and upgrade previews.

Apps, Codex, external services, actual audio/AI generation, collaboration, and payment processing are not complete product implementations. Several secondary settings are previews. Full parity with every reference screen has not been achieved or verified.

## References and cloud verification

The development workspace used 384 source screens and their ZIP under `references/`. These reference files and comparison composites are excluded from the public repository. Source: the [requested Mobbin version](https://mobbin.com/apps/chat-gpt-ios-a96b7f4c-6bfa-4c9d-a6b7-562160feb391/a0b14f48-3d1c-4286-828b-e95ad04fef10/screens).

The existing Revyl app association and cloud build recipe are preserved in `.revyl/config.yaml`. Three historical test definitions are in `.revyl/tests/`. Per the current workflow preference, do not create or run persisted tests; use Revyl CLI device interaction and validation commands. See `evidence/verification.md` for exact build identity, checks, and remaining work.
