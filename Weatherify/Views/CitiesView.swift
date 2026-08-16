import SwiftUI

/// Lists every city that has been searched/cached, with the ability to
/// add a new one or remove an existing one.
struct CitiesView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.savedCities.isEmpty {
                    EmptyCitiesView()
                } else {
                    List {
                        ForEach(viewModel.savedCities) { city in
                            NavigationLink {
                                DetailView(weather: city, forecast: [])
                            } label: {
                                CityRow(weather: city)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Cities")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSearch = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                SearchView()
                    .environmentObject(viewModel)
            }
            .onAppear { viewModel.loadSavedCities() }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteCity(viewModel.savedCities[index])
        }
    }
}

private struct CityRow: View {
    let weather: WeatherDisplayData

    var body: some View {
        HStack(spacing: 12) {
            WeatherIconView(iconCode: weather.iconCode, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(weather.cityName)
                    .font(.headline)
                Text(weather.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(weather.temperature, specifier: "%.0f")°C")
                .font(.title3.weight(.medium))
        }
        .padding(.vertical, 4)
    }
}

private struct EmptyCitiesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "building.2")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No saved cities yet. Tap + to search for one.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
