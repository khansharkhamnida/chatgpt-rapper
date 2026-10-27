# 🎀 Dahyun's Rap Club

An iOS chatbot that replies in playful rap bars, powered by [OpenRouter](https://openrouter.ai). Dahyun, the rap mentor, mixes Singlish and Gen Z slang, remembers things about you, and reads her bars aloud.

> This is a fan-made student project. It is not affiliated with TWICE or Dahyun, and it does not use her real voice or photos.

## ✨ Features

**Chat**
- Chatbot-style UI with message bubbles, avatars and a pinned input bar.
- Full conversation context: every message is sent with the whole transcript (last 20 messages), so she follows up on what you said.
- Chat is saved and restored when you relaunch the app.
- Rap-only replies: 4 lines max, internal rhymes, Singlish + Gen Z slang, matching emojis (⛄ for snowman, ❄️ for frosty).

**Memory**
- **Long-term memory:** tell her your name, pets, hobbies or plans, and she remembers them across chats and relaunches. She confirms by weaving the detail into a bar.
- **Corrections:** "call me Mia now" replaces the old name instead of keeping both.
- **Forgetting:** say "forget my cat", swipe a fact away in the 🧠 screen, or tap **forget all**.
- **Personalised prompt bubbles:** the chips above the input change to match what she knows about you.

**Voice and fun**
- Replies are spoken with Apple's built-in speech, one bar at a time. Emojis are skipped, not read out.
- 🔊 button to mute, and tap any of her bubbles to hear it again.
- **Eagle Dance:** her avatar wobbles and bounces while she thinks and talks.
- Tap her avatar for an emoji confetti burst.
- Croquette theme: cream, blush pink and cherry, with a rounded font, floating decorations and pop-in bubbles.

## 📋 Requirements

| Needs | Version |
|---|---|
| macOS with Xcode | Xcode 26 or later (the OpenRouter package needs Swift tools 6.2) |
| iOS Simulator or iPhone | iOS 26 (the project's deployment target) |
| OpenRouter account | An API key from [openrouter.ai/keys](https://openrouter.ai/keys) |

## 🚀 Setup

### 1. Clone

```bash
git clone https://github.com/khansharkhamnida/chatgpt-rapper.git
cd chatgpt-rapper
open chatgpt-rapper.xcodeproj
```

### 2. Get an OpenRouter API key

1. Sign in at [openrouter.ai](https://openrouter.ai) and create a key under **Keys**.
2. Check **Settings ▸ Guardrails**. Your key can only use the models your guardrails allow. If a request fails with `Model blocked by guardrail`, allow the model there or change the model in the code (see [Choose a model](#choose-a-model)).

### 3. Give the app your key

The app looks for the key in this order:

1. The `apiKey` passed to `RapperChatService(apiKey:)`.
2. The `OPENROUTER_API_KEY` environment variable.
3. An `OPENROUTER_API_KEY` entry in `Info.plist`.

For development, use the environment variable in Xcode:

1. Choose **Product ▸ Scheme ▸ Edit Scheme…**
2. Select **Run ▸ Arguments**.
3. Under **Environment Variables**, click **+**.
4. Name: `OPENROUTER_API_KEY`. Value: your key. Make sure it's ticked.

> ⚠️ **Never commit your key.** `.gitignore` excludes `xcuserdata/` and `xcshareddata/`, where Xcode stores scheme settings. If you ever commit a key by accident, rotate it at openrouter.ai.

Environment variables only exist when you run from Xcode. A build installed on its own won't have the key.

### 4. Run

1. Pick an iPhone simulator at the top of the Xcode window.
2. Press **⌘R**.
3. Type a message and tap the arrow, or tap one of the prompt bubbles.

## 🧪 Try it

| Say | Expect |
|---|---|
| "hi i'm Sofia and i love matcha" | A rap that mentions Sofia and matcha, and new prompt bubbles about you |
| "what's my name?" | She answers with your name |
| "actually call me Mia" | Memory switches to Mia |
| "forget my cat" | The cat fact is removed |
| Tap 🧠 | See, swipe-delete or **forget all** |
| Tap the 🦅 avatar | Confetti |

## 🗂️ Project structure

| File | Role |
|---|---|
| [`ViewController.swift`](chatgpt-rapper/ViewController.swift) | The chat screen: input, bubbles, prompt chips, animations, saving the chat |
| [`RapperChatService.swift`](chatgpt-rapper/RapperChatService.swift) | Talks to OpenRouter. Holds the system prompt, chat history, long-term memory and suggestion generation |
| [`RapperChatError.swift`](chatgpt-rapper/RapperChatError.swift) | Error cases with readable messages |
| [`RapperSpeaker.swift`](chatgpt-rapper/RapperSpeaker.swift) | Text-to-speech with Apple's `AVSpeechSynthesizer`; picks the best installed voice and strips emoji |
| [`ChatBubbleCell.swift`](chatgpt-rapper/ChatBubbleCell.swift) | Message bubble cell, avatars and the `BubbleMessage` model |
| [`MemoryViewController.swift`](chatgpt-rapper/MemoryViewController.swift) | The 🧠 screen that lists, deletes or wipes memories |
| [`Theme.swift`](chatgpt-rapper/Theme.swift) | Colours and rounded fonts |
| [`Packages/swift-openrouter`](Packages/swift-openrouter) | Local copy of the [OpenRouter Swift package](https://github.com/telip007/swift-openrouter) (see below) |

## 🎛️ Customise

### Choose a model

The default is set in `RapperChatService.init`:

```swift
init(apiKey: String? = nil, model: String = "anthropic/claude-haiku-5.5")
```

Model names are `provider/model`. Pick one your key is allowed to use.

### Change her personality

Edit `systemPrompt` in [`RapperChatService.swift`](chatgpt-rapper/RapperChatService.swift). Raise or lower `temperature` (currently `0.9`) in `respond(to:)` for more or less creative replies.

### Change the look

Colours and fonts are in [`Theme.swift`](chatgpt-rapper/Theme.swift). Prompt bubble defaults are the `defaultStarters` list in `ViewController`.

### Make the voice sound better

The simulator's voices are basic. On a real iPhone, go to **Settings ▸ Accessibility ▸ Spoken Content ▸ Voices ▸ English** and download an **Enhanced** or **Premium** voice such as Ava or Zoe. The app picks the best one installed.

## 🧠 How memory works

```mermaid
flowchart LR
    A[You send a message] --> B[Reply uses system prompt + saved facts + last 20 messages]
    B --> C[Reply shown and spoken]
    C --> D[Background request updates the fact list]
    D --> E[Facts saved on device]
    E --> F[New prompt bubbles generated]
```

- Facts are stored locally in `UserDefaults` (up to 30), not on a server.
- After each reply, a small extra request returns the full updated fact list, so corrections replace old facts.
- Deleting a fact also hides earlier messages from the model, so the old detail can't be read back from the chat. Those messages stay on screen.
- Each message makes one or two extra small API calls, so it uses a little more credit.

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| `Missing OPENROUTER_API_KEY` in the chat | Set the variable in the scheme (step 3). Run from Xcode with **⌘R**. |
| `Model blocked by guardrail` / 404 | Your key's guardrails block that model. Allow it at openrouter.ai or pick another model. |
| 401 `Missing Authentication header` | The key is empty or has a typo. |
| Package fails to resolve | **File ▸ Packages ▸ Reset Package Caches**, then build again. |
| `Conflicting options '-warnings-as-errors' and '-suppress-warnings'` | This is why the package is vendored in `Packages/`. Don't swap it back to the remote copy without removing `.treatAllWarnings(as: .error)` from its `Package.swift`. |
| `cannot use bare repository` when building with `xcodebuild` | Run with `GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.bareRepository GIT_CONFIG_VALUE_0=all xcodebuild …` |
| No sound in the simulator | Turn up your Mac volume, check the 🔊 button isn't muted, and try a real iPhone. |

## 📦 About the vendored package

[`swift-openrouter`](https://github.com/telip007/swift-openrouter) 0.1.0 (Apache-2.0) is copied into `Packages/` with one change: its `.treatAllWarnings(as: .error)` setting is removed, because Xcode builds remote packages with warnings suppressed and the two options conflict. Its license is in [`Packages/swift-openrouter/LICENSE`](Packages/swift-openrouter/LICENSE).

## 🔒 Privacy

- The app sends your messages and your saved facts to OpenRouter and the model provider you choose. Don't share anything you wouldn't want sent there.
- Chat history, memories and prompt bubbles are stored only on the device.
