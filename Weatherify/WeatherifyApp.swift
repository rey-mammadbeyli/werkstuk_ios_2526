import SwiftUI

@main
struct WeatherifyApp: App {
    @StateObject private var viewModel = WeatherViewModel()
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
