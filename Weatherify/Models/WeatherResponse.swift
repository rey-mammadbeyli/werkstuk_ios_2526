import Foundation

/// Maps the response of OpenWeather's /data/2.5/weather endpoint.
/// https://openweathermap.org/current
struct WeatherResponse: Decodable {
    let coord: Coordinates
    let weather: [WeatherCondition]
    let main: MainWeather
    let wind: Wind
    let clouds: Clouds?
    let visibility: Int?
    let dt: TimeInterval
    let sys: Sys
    let timezone: Int
    let name: String

    struct Coordinates: Decodable {
        let lon: Double
        let lat: Double
    }

    struct WeatherCondition: Decodable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }

    struct MainWeather: Decodable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case humidity
        }
    }

    struct Wind: Decodable {
        let speed: Double
        let deg: Int?
    }

    struct Clouds: Decodable {
        let all: Int
    }

    struct Sys: Decodable {
        let country: String?
        let sunrise: TimeInterval?
        let sunset: TimeInterval?
    }
}
