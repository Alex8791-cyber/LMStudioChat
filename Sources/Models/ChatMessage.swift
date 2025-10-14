import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let role: Role
    var text: String
    let date: Date
    var isError: Bool

    enum Role: String, Codable {
        case system
        case user
        case assistant
    }

    init(id: UUID = UUID(), role: Role, text: String, date: Date = Date(), isError: Bool = false) {
        self.id = id
        self.role = role
        self.text = text
        self.date = date
        self.isError = isError
    }

    // Convert to OpenAI format
    func toOpenAIMessage() -> [String: String] {
        return ["role": role.rawValue, "content": text]
    }
}
