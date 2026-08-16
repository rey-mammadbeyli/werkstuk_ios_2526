//
//  WeatherifyApp.swift
//  Weatherify
//
//  Created by Nargiz Mammadbeyli on 16/08/2026.
//

import SwiftUI

@main
struct WeatherifyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
