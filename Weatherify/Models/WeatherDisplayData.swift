import Foundation

/// Lightweight, UI-friendly representation of a weather reading. Both the network layer (WeatherResponse) and the persistence layer
/// (CachedWeather) get converted into this single type, so Views never have to know where the data came from.
struct WeatherDisplayData: Identifiable, Equatable {
    var id: String { cityName }

    let cityName: String
    let temperature: Double
    let feelsLike: Double
    let description: String
    let iconCode: String
    let humidity: Int
    let pressure: Int
    let windSpeed: Double
    let latitude: Double
    let longitude: Double
    let lastUpdated: Date

    static func from(response: WeatherResponse) -> WeatherDisplayData {
        WeatherDisplayData(
            cityName: response.name,
            temperature: response.main.temp,
            feelsLike: response.main.feelsLike,
            description: response.weather.first?.description.capitalized ?? "-",
            iconCode: response.weather.first?.icon ?? "01d",
            humidity: response.main.humidity,
            pressure: response.main.pressure,
            windSpeed: response.wind.speed,
            latitude: response.coord.lat,
            longitude: response.coord.lon,
            lastUpdated: Date()
        )
    }
}
