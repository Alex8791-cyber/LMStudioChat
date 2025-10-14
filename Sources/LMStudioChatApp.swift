import SwiftUI

@main
struct LMStudioChatApp: App {
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var conversationStore = ConversationStore()

    var body: some Scene {
        WindowGroup {
            ChatView()
                .environmentObject(settingsStore)
                .environmentObject(conversationStore)
                .onAppear {
                    conversationStore.load()
                }
        }
    }
}
