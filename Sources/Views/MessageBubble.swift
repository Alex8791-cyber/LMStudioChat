import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(bubbleColor)
                    .foregroundColor(textColor)
                    .cornerRadius(16)
                    .textSelection(.enabled)
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = message.text
                        } label: {
                            Label("Kopieren", systemImage: "doc.on.doc")
                        }
                    }

                Text(message.date, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if message.role == .assistant {
                Spacer(minLength: 60)
            }
        }
    }

    private var bubbleColor: Color {
        if message.isError {
            return Color.red.opacity(0.2)
        }
        return message.role == .user ? Color.blue : Color.gray.opacity(0.2)
    }

    private var textColor: Color {
        message.role == .user ? .white : .primary
    }
}
