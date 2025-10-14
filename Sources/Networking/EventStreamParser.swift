import Foundation

struct EventStreamParser {
    private(set) var isDone = false

    mutating func parse(line: String) -> String? {
        // SSE format: "data: {...}" or "data: [DONE]"
        guard line.hasPrefix("data: ") else {
            return nil
        }

        let dataContent = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)

        // Check for stream end
        if dataContent == "[DONE]" {
            isDone = true
            return nil
        }

        // Parse JSON delta
        guard let data = dataContent.data(using: .utf8) else {
            return nil
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let choices = json?["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let delta = firstChoice["delta"] as? [String: Any],
                  let content = delta["content"] as? String else {
                return nil
            }
            return content
        } catch {
            return nil
        }
    }
}
