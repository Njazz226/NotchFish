import Cocoa

/// Shared settings model — persisted via UserDefaults.
class FishSettings: ObservableObject {
    static let shared = FishSettings()

    // MARK: - Color Presets

    enum FishColor: String, CaseIterable {
        case orange = "orange"
        case blue = "blue"
        case neon = "neon"
        case ghost = "ghost"
        case red = "red"
        case purple = "purple"

        var displayName: String {
            switch self {
            case .orange: return "Golden"
            case .blue:   return "Tropical"
            case .neon:   return "Neon"
            case .ghost:  return "Ghost"
            case .red:    return "Red"
            case .purple: return "Purple"
            }
        }

        var bodyColor: NSColor {
            switch self {
            case .orange: return NSColor(red: 1.0, green: 0.55, blue: 0.15, alpha: 1.0)
            case .blue:   return NSColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
            case .neon:   return NSColor(red: 0.1, green: 1.0, blue: 0.5, alpha: 1.0)
            case .ghost:  return NSColor(red: 0.85, green: 0.85, blue: 0.95, alpha: 0.6)
            case .red:    return NSColor(red: 0.9, green: 0.2, blue: 0.15, alpha: 1.0)
            case .purple: return NSColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 1.0)
            }
        }

        var bellyColor: NSColor {
            switch self {
            case .orange: return NSColor(red: 1.0, green: 0.75, blue: 0.4, alpha: 0.5)
            case .blue:   return NSColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.5)
            case .neon:   return NSColor(red: 0.4, green: 1.0, blue: 0.7, alpha: 0.5)
            case .ghost:  return NSColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 0.3)
            case .red:    return NSColor(red: 1.0, green: 0.5, blue: 0.4, alpha: 0.5)
            case .purple: return NSColor(red: 0.8, green: 0.5, blue: 1.0, alpha: 0.5)
            }
        }

        var strokeColor: NSColor { bodyColor.blended(withFraction: 0.3, of: .black) ?? bodyColor }
        var tailColor: NSColor { bodyColor.blended(withFraction: 0.1, of: .black) ?? bodyColor }
        var finColor: NSColor { bodyColor.blended(withFraction: 0.15, of: .black) ?? bodyColor }
        var mouthColor: NSColor { bodyColor.blended(withFraction: 0.4, of: .black) ?? bodyColor }
        var eyelidColor: NSColor { bodyColor }
        var scaleColor: NSColor {
            bodyColor.blended(withFraction: 0.2, of: .black)?.withAlphaComponent(0.4) ?? bodyColor
        }
    }

    // MARK: - Mood Presets

    enum FishMood: String, CaseIterable {
        case auto = "auto"
        case happy = "happy"
        case calm = "calm"
        case nervous = "nervous"

        var displayName: String {
            switch self {
            case .auto:    return "Auto"
            case .happy:   return "Happy"
            case .calm:    return "Calm"
            case .nervous: return "Nervous"
            }
        }

        var scareRadiusMult: CGFloat {
            switch self {
            case .auto: return 1.0
            case .happy: return 0.7
            case .calm: return 0.85
            case .nervous: return 1.5
            }
        }

        var speedMult: CGFloat {
            switch self {
            case .auto: return 1.0
            case .happy: return 1.2
            case .calm: return 0.7
            case .nervous: return 1.1
            }
        }

        var fleeSpeedMult: CGFloat {
            switch self {
            case .auto: return 1.0
            case .happy: return 0.9
            case .calm: return 0.8
            case .nervous: return 1.4
            }
        }

        var bubbleFreqMult: Double {
            switch self {
            case .auto: return 1.0
            case .happy: return 0.5
            case .calm: return 1.5
            case .nervous: return 2.0
            }
        }

        var sleepDelayMult: Double {
            switch self {
            case .auto: return 1.0
            case .happy: return 1.5
            case .calm: return 0.6
            case .nervous: return 2.0
            }
        }
    }

    // MARK: - Published Properties

    @Published var fishColor: FishColor = .orange {
        didSet { UserDefaults.standard.set(fishColor.rawValue, forKey: "fishColor") }
    }

    @Published var speedMultiplier: Double = 1.0 {
        didSet { UserDefaults.standard.set(speedMultiplier, forKey: "speedMult") }
    }

    @Published var sizeMultiplier: Double = 1.0 {
        didSet { UserDefaults.standard.set(sizeMultiplier, forKey: "sizeMult") }
    }

    @Published var sleepEnabled: Bool = true {
        didSet { UserDefaults.standard.set(sleepEnabled, forKey: "sleepEnabled") }
    }

    @Published var fishMood: FishMood = .auto {
        didSet { UserDefaults.standard.set(fishMood.rawValue, forKey: "fishMood") }
    }

    // MARK: - Init

    private init() {
        if let saved = UserDefaults.standard.string(forKey: "fishColor"),
           let color = FishColor(rawValue: saved) {
            fishColor = color
        }
        let savedSpeed = UserDefaults.standard.double(forKey: "speedMult")
        if savedSpeed > 0 { speedMultiplier = savedSpeed }
        let savedSize = UserDefaults.standard.double(forKey: "sizeMult")
        if savedSize > 0 { sizeMultiplier = savedSize }
        sleepEnabled = UserDefaults.standard.object(forKey: "sleepEnabled") as? Bool ?? true
        if let savedMood = UserDefaults.standard.string(forKey: "fishMood"),
           let mood = FishMood(rawValue: savedMood) {
            fishMood = mood
        }
    }
}
