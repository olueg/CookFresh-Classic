//
//  ChatDetailView.swift
//  CookFresh-Classic
//

import SwiftUI
import CoreData

struct ChatDetailView: View {
    @ObservedObject var session: ChatSession

    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("gemini_api_key") private var apiKey: String = ""

    @FetchRequest private var messages: FetchedResults<ChatMessage>

    @State private var input: String = ""
    @State private var isSending = false
    @State private var errorMessage: String?

    init(session: ChatSession) {
        self.session = session
        let request: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ChatMessage.createdAt, ascending: true)]
        request.predicate = NSPredicate(format: "session == %@", session)
        _messages = FetchRequest(fetchRequest: request, animation: .default)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        if isSending {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            HStack {
                TextField("Message", text: $input)
                    .textFieldStyle(.roundedBorder)
                Button {
                    Task { await send() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            }
            .padding()
        }
        .navigationTitle(session.title ?? "Chat")
    }

    private func send() async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""

        let userMsg = ChatMessage(context: viewContext)
        userMsg.id = UUID()
        userMsg.role = "user"
        userMsg.content = text
        userMsg.createdAt = Date()
        userMsg.session = session
        session.updatedAt = Date()
        if session.title == nil || session.title?.isEmpty == true {
            session.title = String(text.prefix(40))
        }
        try? viewContext.save()

        isSending = true
        errorMessage = nil
        defer { isSending = false }

        let history = messages.map { (role: $0.role ?? "user", content: $0.content ?? "") }
        do {
            let reply = try await GeminiService.shared.send(messages: history, apiKey: apiKey)
            let assistantMsg = ChatMessage(context: viewContext)
            assistantMsg.id = UUID()
            assistantMsg.role = "assistant"
            assistantMsg.content = reply
            assistantMsg.createdAt = Date()
            assistantMsg.session = session
            session.updatedAt = Date()
            try? viewContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == "user" { Spacer(minLength: 0) }
            Text(message.content ?? "")
                .padding(10)
                .background(message.role == "user" ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundColor(message.role == "user" ? .white : .primary)
                .cornerRadius(12)
            if message.role == "assistant" { Spacer(minLength: 0) }
        }
    }
}