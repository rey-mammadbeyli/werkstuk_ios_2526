import SwiftUI

/// Home screen: current weather for the user's GPS location, a manual
/// refresh button, an offline banner when relevant, and the "last updated"
/// timestamp required by the assignment.
struct HomeView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isOffline {
                        OfflineBannerView(lastUpdated: viewModel.lastUpdated)
                    }

                    if let weather = viewModel.currentWeather {
                        WeatherSummaryCard(weather: weather)

                        NavigationLink {
                            DetailView(weather: weather, forecast: viewModel.forecast)
                        } label: {
                            Label("View details", systemImage: "chevron.right.circle")
                                .font(.subheadline.weight(.semibold))
                        }
                    } else if viewModel.isLoading {
                        ProgressView("Fetching weather…")
                            .padding(.top, 60)
                    } else {
                        FallbackStateView(
                            errorMessage: viewModel.errorMessage,
                            onRetry: { viewModel.refreshCurrentLocation() }
                        )
                    }

                    if let lastUpdated = viewModel.lastUpdated {
                        Text("Last updated: \(lastUpdated.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Weather")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.refreshCurrentLocation()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                SearchView()
                    .environmentObject(viewModel)
            }
            .onAppear { viewModel.onAppear() }
            .alert("Something went wrong", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    /// Only surfaces the error as a blocking alert when there is no data
    /// (cached or live) to fall back on.
    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil && viewModel.currentWeather == nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}

private struct WeatherSummaryCard: View {
    let weather: WeatherDisplayData

    var body: some View {
        VStack(spacing: 12) {
            Text(weather.cityName)
                .font(.title2.weight(.semibold))

            WeatherIconView(iconCode: weather.iconCode, size: 90)

            Text("\(weather.temperature, specifier: "%.0f")°C")
                .font(.system(size: 56, weight: .thin))

            Text(weather.description)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct FallbackStateView: View {
    let errorMessage: String?
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(errorMessage ?? "No weather data yet.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Try again", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding(.top, 60)
    }
}

#Preview {
    HomeView()
        .environmentObject(WeatherViewModel())
}
