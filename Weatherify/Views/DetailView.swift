import SwiftUI

/// Detail screen: extra weather metrics (humidity, pressure, wind,
/// coordinates) plus the optional temperature-over-time chart.
struct DetailView: View {
    let weather: WeatherDisplayData
    let forecast: [ForecastResponse.ForecastEntry]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(spacing: 8) {
                    WeatherIconView(iconCode: weather.iconCode, size: 80)
                    Text("\(weather.temperature, specifier: "%.1f")°C")
                        .font(.system(size: 42, weight: .light))
                    Text("Feels like \(weather.feelsLike, specifier: "%.1f")°C")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                if !forecast.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Temperature (next 24h)")
                            .font(.headline)
                        TemperatureChartView(entries: forecast)
                    }
                }

                VStack(spacing: 0) {
                    DetailRow(icon: "humidity.fill", title: "Humidity", value: "\(weather.humidity)%")
                    Divider()
                    DetailRow(icon: "gauge", title: "Pressure", value: "\(weather.pressure) hPa")
                    Divider()
                    DetailRow(icon: "wind", title: "Wind speed", value: String(format: "%.1f m/s", weather.windSpeed))
                    Divider()
                    DetailRow(icon: "location.fill", title: "Coordinates", value: String(format: "%.2f, %.2f", weather.latitude, weather.longitude))
                }
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .navigationTitle(weather.cityName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
