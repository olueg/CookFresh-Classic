//
//  ContentView.swift
//  CookFresh-Classic
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        ChatListView()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}