import SwiftUI

/// Home screen: current weather for the user's GPS location, a manual
/// refresh button, an offline banner when relevant, and the "last updated"
/// timestamp required by the assignment.
struct HomeView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.isOffline {
                            OfflineBannerView(lastUpdated: viewModel.lastUpdated)
                        }

                        if let weather = viewModel.currentWeather {
                            WeatherSummaryCard(weather: weather)
                            QuickStatsRow(weather: weather)

                            NavigationLink {
                                DetailView(weather: weather, forecast: viewModel.forecast)
                            } label: {
                                Label("View details", systemImage: "chevron.right.circle.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(.white.opacity(0.2), in: Capsule())
                            }
                        } else if viewModel.isLoading {
                            ProgressView("Fetching weather…")
                                .tint(.white)
                                .foregroundStyle(.white)
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
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Weather")
            .toolbarColorScheme(.dark, for: .navigationBar)
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

    private var backgroundGradient: LinearGradient {
        WeatherTheme.gradient(for: viewModel.currentWeather?.iconCode)
    }
}

/// Maps OpenWeather icon codes to a themed gradient, so the Home screen's
/// mood visually matches the current conditions (sunny, cloudy, rainy,
/// stormy, snowy, foggy, or night-time).
enum WeatherTheme {
    static func gradient(for iconCode: String?) -> LinearGradient {
        let colors: [Color]

        switch iconCode {
        case "01d":
            colors = [Color(red: 0.98, green: 0.68, blue: 0.28), Color(red: 0.30, green: 0.62, blue: 0.93)]
        case "01n":
            colors = [Color(red: 0.14, green: 0.15, blue: 0.35), Color(red: 0.30, green: 0.18, blue: 0.48)]
        case "02d", "03d", "04d":
            colors = [Color(red: 0.45, green: 0.60, blue: 0.75), Color(red: 0.62, green: 0.70, blue: 0.80)]
        case "02n", "03n", "04n":
            colors = [Color(red: 0.20, green: 0.22, blue: 0.32), Color(red: 0.35, green: 0.38, blue: 0.48)]
        case "09d", "09n", "10d", "10n":
            colors = [Color(red: 0.20, green: 0.35, blue: 0.55), Color(red: 0.35, green: 0.45, blue: 0.60)]
        case "11d", "11n":
            colors = [Color(red: 0.22, green: 0.18, blue: 0.35), Color(red: 0.45, green: 0.20, blue: 0.30)]
        case "13d", "13n":
            colors = [Color(red: 0.65, green: 0.75, blue: 0.85), Color(red: 0.85, green: 0.90, blue: 0.95)]
        case "50d", "50n":
            colors = [Color(red: 0.55, green: 0.58, blue: 0.60), Color(red: 0.70, green: 0.72, blue: 0.74)]
        default:
            colors = [Color(red: 0.35, green: 0.55, blue: 0.85), Color(red: 0.55, green: 0.70, blue: 0.90)]
        }

        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
}

private struct WeatherSummaryCard: View {
    let weather: WeatherDisplayData

    var body: some View {
        VStack(spacing: 12) {
            Text(weather.cityName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

            WeatherIconView(iconCode: weather.iconCode, size: 90)

            Text("\(weather.temperature, specifier: "%.0f")°C")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(.white)

            Text(weather.description)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(0.25), lineWidth: 1)
        )
    }
}

/// Three colorful quick-stat pills giving an at-a-glance summary beyond
/// just temperature: how it actually feels, humidity, and wind.
private struct QuickStatsRow: View {
    let weather: WeatherDisplayData

    var body: some View {
        HStack(spacing: 12) {
            StatPill(
                icon: "thermometer.sun.fill",
                title: "Feels like",
                value: "\(Int(weather.feelsLike.rounded()))°C",
                tint: .orange
            )
            StatPill(
                icon: "humidity.fill",
                title: "Humidity",
                value: "\(weather.humidity)%",
                tint: .blue
            )
            StatPill(
                icon: "wind",
                title: "Wind",
                value: String(format: "%.0f m/s", weather.windSpeed),
                tint: .mint
            )
        }
    }
}

private struct StatPill: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct FallbackStateView: View {
    let errorMessage: String?
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.slash")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.8))
            Text(errorMessage ?? "No weather data yet.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.85))
            Button("Try again", action: onRetry)
                .buttonStyle(.borderedProminent)
                .tint(.white.opacity(0.25))
        }
        .padding(.top, 60)
    }
}

#Preview {
    HomeView()
        .environmentObject(WeatherViewModel())
}
