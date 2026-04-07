import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = FishSettings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("NotchFish Settings")
                .font(.headline)

            // Color picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Color")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack(spacing: 8) {
                    ForEach(FishSettings.FishColor.allCases, id: \.self) { color in
                        Button(action: { settings.fishColor = color }) {
                            Circle()
                                .fill(Color(color.bodyColor))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(settings.fishColor == color ? Color.white : Color.clear, lineWidth: 2)
                                )
                                .shadow(color: settings.fishColor == color ? .white.opacity(0.5) : .clear, radius: 3)
                        }
                        .buttonStyle(.plain)
                        .help(color.displayName)
                    }
                }
            }

            // Speed slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Speed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.1fx", settings.speedMultiplier))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Slider(value: $settings.speedMultiplier, in: 0.5...2.0, step: 0.1)
            }

            // Size slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Size")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.1fx", settings.sizeMultiplier))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Slider(value: $settings.sizeMultiplier, in: 0.6...1.5, step: 0.1)
            }

            // Mood picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Mood")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack(spacing: 6) {
                    ForEach(FishSettings.FishMood.allCases, id: \.self) { mood in
                        Button(action: { settings.fishMood = mood }) {
                            Text(mood.displayName)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(settings.fishMood == mood
                                              ? Color.accentColor.opacity(0.3)
                                              : Color.gray.opacity(0.15))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(settings.fishMood == mood
                                                ? Color.accentColor
                                                : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Sleep toggle
            Toggle("Falls asleep", isOn: $settings.sleepEnabled)
                .font(.subheadline)

            Divider()

            Button("Reset") {
                settings.fishColor = .orange
                settings.speedMultiplier = 1.0
                settings.sizeMultiplier = 1.0
                settings.sleepEnabled = true
                settings.fishMood = .auto
            }
            .font(.caption)
        }
        .padding(16)
        .frame(width: 280)
    }
}
