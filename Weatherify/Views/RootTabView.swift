import SwiftUI

/// Root tab bar hosting the app's four main sections.
struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            CitiesView()
                .tabItem {
                    Label("Cities", systemImage: "building.2.fill")
                }

            ForecastView()
                .tabItem {
                    Label("Forecast", systemImage: "calendar")
                }

            MapTabView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
        }
    }
}
