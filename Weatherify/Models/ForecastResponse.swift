import Foundation

/// Maps the response of OpenWeather's /data/2.5/forecast endpoint
/// (3-hour step forecast, used to render the temperature chart).
/// https://openweathermap.org/forecast5
struct ForecastResponse: Decodable {
    let list: [ForecastEntry]
    let city: City

    struct ForecastEntry: Decodable, Identifiable {
        var id: TimeInterval { dt }
        let dt: TimeInterval
        let main: MainForecast
        let weather: [Weather]

        struct MainForecast: Decodable {
            let temp: Double
        }

        struct Weather: Decodable {
            let icon: String
            let description: String
        }

        var date: Date { Date(timeIntervalSince1970: dt) }
    }

    struct City: Decodable {
        let name: String
    }
}
