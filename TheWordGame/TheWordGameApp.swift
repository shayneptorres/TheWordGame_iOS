//
//  TheWordGameApp.swift
//  TheWordGame
//
//  Created by Shayne Torres on 10/28/22.
//

import SwiftUI

@main
struct TheWordGameApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                MainView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("Game View", systemImage: "play.fill")
                    }
                WordsView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("Game View", systemImage: "list.bullet")
                    }
            }
        }
    }
}
