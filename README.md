# NotchFish 🐠

A tiny pixel fish that lives in your MacBook's notch area. It swims back and forth across the menu bar, hides behind the camera notch when you scare it with your mouse, and occasionally blows bubbles.

![NotchFish demo](NotchFish.gif)

## Features

- **Procedural pixel fish** — no image assets, fully drawn with SpriteKit shapes
- **Notch-aware** — the fish knows where your camera notch is and hides behind it when scared
- **Reactive to mouse** — move your cursor near the fish and it flees; corner it and it cowers
- **Mood system** — happy, calm, nervous, or auto-cycling moods that affect behavior
- **Sleep mode** — the fish dozes off after periods of inactivity (toggleable)
- **Customizable** — change color (6 presets), size, speed, and mood from the menu bar settings
- **Lightweight** — lives entirely in the menu bar, no Dock icon, minimal resource usage

## Requirements

- macOS 13.0 or later
- MacBook with a notch (works without one too, but the hiding behavior is best with a notch)
- Apple Silicon or Intel Mac

## Building

NotchFish uses Swift Package Manager with no external dependencies.

```bash
git clone https://github.com/Njazz226/NotchFish.git
cd NotchFish
swift build
swift run
```

Or build a release version:

```bash
swift build -c release
```

The built binary will be at `.build/release/NotchFish`.

## Usage

Once running, NotchFish appears as a small fish icon in your menu bar. Click it to access settings:

- **Color** — pick from 6 fish color presets
- **Speed** — adjust swimming speed (0.5x to 2x)
- **Size** — adjust fish size (0.6x to 1.5x)
- **Mood** — set happy, calm, nervous, or let it auto-cycle
- **Sleep** — toggle whether the fish falls asleep when idle

Right-click or use the Quit option to close.

## Project Structure

```
NotchFish/
├── Package.swift
├── NotchFish/
│   ├── App/
│   │   ├── NotchFishApp.swift      # SwiftUI entry point
│   │   ├── AppDelegate.swift       # Window setup, mouse tracking
│   │   └── Info.plist
│   ├── Fish/
│   │   ├── FishScene.swift         # Core SpriteKit scene & update loop
│   │   ├── FishNode.swift          # Procedural fish drawing
│   │   ├── FishStates.swift        # State machine (idle, swimming, fleeing, cowering)
│   │   ├── FishAnimations.swift    # Pupil tracking, sleep, bubbles
│   │   └── FishMood.swift          # Mood system & auto-cycling
│   └── Settings/
│       ├── FishSettings.swift      # Settings model with UserDefaults
│       └── SettingsView.swift      # SwiftUI settings panel
```

## License

MIT License — see [LICENSE](LICENSE) for details.
