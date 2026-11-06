//
//  CookFresh_ClassicApp.swift
//  CookFresh-Classic
//
//  Created by Olaf on 06.11.26.
//

import SwiftUI

@main
struct CookFresh_ClassicApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
