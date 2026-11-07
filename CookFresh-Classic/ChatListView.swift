//
//  ChatListView.swift
//  CookFresh-Classic
//

import SwiftUI
import CoreData

struct ChatListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ChatSession.updatedAt, ascending: false)],
        animation: .default)
    private var sessions: FetchedResults<ChatSession>

    @State private var showSettings = false

    var body: some View {
        NavigationView {
            List {
                ForEach(sessions) { session in
                    NavigationLink {
                        ChatDetailView(session: session)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(session.title ?? "New Chat")
                                .font(.headline)
                            if let date = session.updatedAt {
                                Text(date, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteSessions)
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addSession) {
                        Label("New Chat", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .overlay {
                if sessions.isEmpty {
                    VStack {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No chats yet")
                            .foregroundColor(.secondary)
                        Text("Tap + to start a new chat.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private func addSession() {
        withAnimation {
            let session = ChatSession(context: viewContext)
            session.id = UUID()
            session.createdAt = Date()
            session.updatedAt = Date()
            session.title = ""
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteSessions(offsets: IndexSet) {
        withAnimation {
            offsets.map { sessions[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}