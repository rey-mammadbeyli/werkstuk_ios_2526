import Foundation

/// A single day's aggregated forecast, derived by grouping OpenWeather's
/// 3-hour-step forecast entries by calendar day.
struct DailyForecast: Identifiable {
    let id = UUID()
    let date: Date
    let minTemp: Double
    let maxTemp: Double
    let iconCode: String
    let description: String

    static func group(from entries: [ForecastResponse.ForecastEntry]) -> [DailyForecast] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.date)
        }

        return grouped.keys.sorted().compactMap { day in
            guard let dayEntries = grouped[day], !dayEntries.isEmpty else { return nil }
            let temps = dayEntries.map { $0.main.temp }

            // Use the entry closest to midday as the representative icon/description.
            let representative = dayEntries.min { lhs, rhs in
                abs(calendar.component(.hour, from: lhs.date) - 12)
                    < abs(calendar.component(.hour, from: rhs.date) - 12)
            } ?? dayEntries[0]

            return DailyForecast(
                date: day,
                minTemp: temps.min() ?? representative.main.temp,
                maxTemp: temps.max() ?? representative.main.temp,
                iconCode: representative.weather.first?.icon ?? "01d",
                description: representative.weather.first?.description.capitalized ?? "-"
            )
        }
    }
}
