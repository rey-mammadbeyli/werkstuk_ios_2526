import SwiftUI

/// Lets the user manually type a city name and look up its weather,
/// independently of GPS location.
struct SearchView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var cityName = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    TextField("Enter a city name", text: $cityName)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.search)
                        .onSubmit(performSearch)
                        .autocorrectionDisabled()

                    Button("Search", action: performSearch)
                        .disabled(cityName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)

                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if let result = viewModel.searchResults {
                    SearchResultCard(weather: result) {
                        viewModel.selectSearchResultAsCurrent()
                        dismiss()
                    }
                    .padding(.horizontal)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Search city")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func performSearch() {
        let query = cityName
        Task { await viewModel.searchCity(query) }
    }
}

private struct SearchResultCard: View {
    let weather: WeatherDisplayData
    let onUseAsCurrent: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(weather.cityName)
                .font(.title3.weight(.semibold))
            WeatherIconView(iconCode: weather.iconCode, size: 60)
            Text("\(weather.temperature, specifier: "%.0f")°C — \(weather.description)")
                .font(.subheadline)

            Button("Set as home screen", action: onUseAsCurrent)
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
