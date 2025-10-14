import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        Form {
            Section("Server") {
                TextField("Server-URL", text: $settings.serverURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)

                TextField("Modell-ID", text: $settings.modelID)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                TextField("API-Key (optional)", text: $settings.apiKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Section("Parameter") {
                VStack(alignment: .leading) {
                    Text("Temperatur: \(settings.temperature, specifier: "%.2f")")
                    Slider(value: $settings.temperature, in: 0...2, step: 0.1)
                }

                VStack(alignment: .leading) {
                    Text("Top-p: \(settings.topP, specifier: "%.2f")")
                    Slider(value: $settings.topP, in: 0...1, step: 0.05)
                }

                Stepper("Max Tokens: \(settings.maxTokens)", value: $settings.maxTokens, in: 64...4096, step: 64)
            }

            Section("System-Prompt") {
                TextEditor(text: $settings.systemPrompt)
                    .frame(minHeight: 100)
            }

            Section {
                Text("Stelle sicher, dass dein Heimserver LM Studio läuft, Port 1234 per Router freigegeben ist (Port Forwarding) und du DynDNS oder deine öffentliche IP verwendest.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
