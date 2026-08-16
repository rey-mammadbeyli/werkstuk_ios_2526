import SwiftUI
import MapKit

/// Shows every saved/cached city (plus the current-location reading) as
/// pins on a map, each labelled with its icon and temperature.
struct MapTabView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedWeather: WeatherDisplayData?

    private var allLocations: [WeatherDisplayData] {
        var locations = viewModel.savedCities
        if let current = viewModel.currentWeather,
           !locations.contains(where: { $0.cityName == current.cityName }) {
            locations.append(current)
        }
        return locations
    }

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                ForEach(allLocations) { weather in
                    Annotation(
                        weather.cityName,
                        coordinate: CLLocationCoordinate2D(latitude: weather.latitude, longitude: weather.longitude)
                    ) {
                        Button {
                            selectedWeather = weather
                        } label: {
                            VStack(spacing: 2) {
                                WeatherIconView(iconCode: weather.iconCode, size: 26)
                                Text("\(weather.temperature, specifier: "%.0f")°")
                                    .font(.caption2.bold())
                            }
                            .padding(6)
                            .background(.thinMaterial, in: Circle())
                        }
                    }
                }
            }
            .navigationTitle("Map")
            .onAppear { viewModel.loadSavedCities() }
            .sheet(item: $selectedWeather) { weather in
                NavigationStack {
                    DetailView(weather: weather, forecast: [])
                }
            }
        }
    }
}
