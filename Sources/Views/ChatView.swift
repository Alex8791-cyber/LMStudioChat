import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var conversationStore: ConversationStore
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages.filter { $0.role != .system }) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()

                // Input area
                HStack(spacing: 12) {
                    TextField("Nachricht...", text: $viewModel.inputText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...6)
                        .disabled(viewModel.isLoading)
                        .onSubmit {
                            viewModel.sendMessage(settings: settingsStore, conversationStore: conversationStore)
                        }

                    if viewModel.isLoading {
                        Button("Stop") {
                            viewModel.cancelStream()
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button {
                            viewModel.sendMessage(settings: settingsStore, conversationStore: conversationStore)
                        } label: {
                            Image(systemName: "paperplane.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding()
            }
            .navigationTitle("LM Studio Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Löschen") {
                        viewModel.clearMessages(conversationStore: conversationStore)
                    }
                    .disabled(viewModel.messages.isEmpty)
                }
            }
            .sheet(isPresented: $showSettings) {
                NavigationView {
                    SettingsView()
                        .navigationTitle("Einstellungen")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Fertig") {
                                    showSettings = false
                                }
                            }
                        }
                }
            }
            .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .onAppear {
                viewModel.loadMessages(from: conversationStore)
            }
        }
    }
}
