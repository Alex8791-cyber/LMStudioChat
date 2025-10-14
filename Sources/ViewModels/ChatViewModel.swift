import Foundation
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let client = LMStudioClient()
    private var streamTask: Task<Void, Never>?

    func sendMessage(settings: SettingsStore, conversationStore: ConversationStore) {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !isLoading else { return }

        let userText = inputText
        inputText = ""

        // Add user message
        let userMessage = ChatMessage(role: .user, text: userText)
        messages.append(userMessage)
        conversationStore.messages = messages
        conversationStore.save()

        // Start streaming
        isLoading = true
        errorMessage = nil

        // Create empty assistant message
        let assistantMessage = ChatMessage(role: .assistant, text: "")
        messages.append(assistantMessage)

        // Build context (system + history)
        var contextMessages: [ChatMessage] = [
            ChatMessage(role: .system, text: settings.systemPrompt)
        ]
        contextMessages.append(contentsOf: messages.filter { !$0.isError })

        streamTask = Task {
            do {
                let stream = await client.send(messages: contextMessages, settings: settings)

                for try await content in stream {
                    if let index = messages.firstIndex(where: { $0.id == assistantMessage.id }) {
                        messages[index].text += content
                    }
                }

                isLoading = false
                conversationStore.messages = messages
                conversationStore.save()

            } catch {
                isLoading = false

                // Remove empty assistant message
                messages.removeAll { $0.id == assistantMessage.id }

                // Add error message
                let errorMsg = ChatMessage(
                    role: .assistant,
                    text: error.localizedDescription,
                    isError: true
                )
                messages.append(errorMsg)

                errorMessage = error.localizedDescription
                conversationStore.messages = messages
                conversationStore.save()
            }
        }
    }

    func cancelStream() {
        streamTask?.cancel()
        streamTask = nil
        isLoading = false
    }

    func clearMessages(conversationStore: ConversationStore) {
        messages.removeAll()
        conversationStore.messages = []
        conversationStore.save()
    }

    func loadMessages(from store: ConversationStore) {
        messages = store.messages
    }
}
