import Foundation

enum LMStudioError: LocalizedError {
    case invalidURL
    case httpError(statusCode: Int, message: String)
    case decodingError(String)
    case networkError(Error)
    case streamInterrupted

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ungültige Server-URL"
        case .httpError(let code, let message):
            return "HTTP \(code): \(message)"
        case .decodingError(let detail):
            return "JSON-Fehler: \(detail)"
        case .networkError(let error):
            return "Netzwerkfehler: \(error.localizedDescription)"
        case .streamInterrupted:
            return "Stream unterbrochen"
        }
    }
}

actor LMStudioClient {
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 600
        self.session = URLSession(configuration: config)
    }

    // Streaming chat completion
    func send(messages: [ChatMessage], settings: SettingsStore) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let url = URL(string: settings.serverURL) else {
                        throw LMStudioError.invalidURL
                    }

                    // Build request body
                    let openAIMessages = messages.map { $0.toOpenAIMessage() }
                    let body: [String: Any] = [
                        "model": settings.modelID,
                        "messages": openAIMessages,
                        "temperature": settings.temperature,
                        "top_p": settings.topP,
                        "max_tokens": settings.maxTokens,
                        "stream": true
                    ]

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                    // Add API key header if not empty
                    if !settings.apiKey.isEmpty {
                        request.setValue("Bearer \(settings.apiKey)", forHTTPHeaderField: "Authorization")
                    }

                    request.httpBody = try JSONSerialization.data(withJSONObject: body)

                    // Start streaming request
                    let (bytes, response) = try await session.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw LMStudioError.networkError(URLError(.badServerResponse))
                    }

                    guard (200...299).contains(httpResponse.statusCode) else {
                        throw LMStudioError.httpError(statusCode: httpResponse.statusCode, message: "Request failed")
                    }

                    // Parse SSE stream
                    var parser = EventStreamParser()

                    for try await line in bytes.lines {
                        if let content = parser.parse(line: line) {
                            continuation.yield(content)
                        }
                        if parser.isDone {
                            break
                        }
                    }

                    continuation.finish()

                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
