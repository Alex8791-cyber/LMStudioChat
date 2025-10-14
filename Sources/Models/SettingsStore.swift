import Foundation
import SwiftUI

class SettingsStore: ObservableObject {
    @AppStorage("serverURL") var serverURL: String = "http://dein-dyndns.ddns.net:1234/v1/chat/completions"
    @AppStorage("modelID") var modelID: String = "qwen/qwen3-32b"
    @AppStorage("apiKey") var apiKey: String = "lm-studio"
    @AppStorage("temperature") var temperature: Double = 0.7
    @AppStorage("topP") var topP: Double = 1.0
    @AppStorage("maxTokens") var maxTokens: Int = 512
    @AppStorage("systemPrompt") var systemPrompt: String = "Du bist ein hilfreicher Assistent."

    var hasValidURL: Bool {
        guard let url = URL(string: serverURL) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }
}
