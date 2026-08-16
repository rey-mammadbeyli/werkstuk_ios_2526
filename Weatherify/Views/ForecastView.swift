import SwiftUI

/// Multi-day forecast (aggregated from OpenWeather's 3-hour-step data)
/// for whichever city is currently shown on the Home screen.
struct ForecastView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    var body: some View {
        NavigationStack {
            Group {
                if let weather = viewModel.currentWeather, !viewModel.dailyForecast.isEmpty {
                    List(viewModel.dailyForecast) { day in
                        HStack {
                            Text(day.date, format: .dateTime.weekday(.wide))
                                .frame(width: 100, alignment: .leading)
                            WeatherIconView(iconCode: day.iconCode, size: 32)
                            Text(day.description)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            Spacer()
                            Text("\(day.maxTemp, specifier: "%.0f")° / \(day.minTemp, specifier: "%.0f")°")
                                .font(.subheadline.weight(.medium))
                        }
                        .padding(.vertical, 4)
                    }
                    .navigationTitle("\(weather.cityName) Forecast")
                } else {
                    EmptyForecastView()
                        .navigationTitle("Forecast")
                }
            }
        }
    }
}

private struct EmptyForecastView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No forecast yet. Load weather on the Home tab first.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
