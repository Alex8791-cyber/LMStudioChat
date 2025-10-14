import Foundation

class ConversationStore: ObservableObject {
    @Published var messages: [ChatMessage] = []

    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("conversation.json")
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(messages)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save conversation: \(error)")
        }
    }

    func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            messages = try JSONDecoder().decode([ChatMessage].self, from: data)
        } catch {
            // File doesn't exist or is invalid - start fresh
            messages = []
        }
    }
}
