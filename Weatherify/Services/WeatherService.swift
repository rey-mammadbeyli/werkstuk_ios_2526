import Foundation
import Alamofire

enum WeatherServiceError: LocalizedError {
    case invalidCity
    case network(String)

    var errorDescription: String? {
        switch self {
        case .invalidCity:
            return "City not found. Check the spelling and try again."
        case .network(let message):
            return message
        }
    }
}

/// Wraps all OpenWeather API calls.
/// Alamofire library is used here as the required external networking library; it
/// sits on top of URLSession and simplifies request building, response
/// validation and error handling compared to using URLSession directly.
final class WeatherService {
    static let shared = WeatherService()

    private let session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        return Session(configuration: configuration)
    }()

    func fetchCurrentWeather(city: String) async throws -> WeatherResponse {
        let parameters: Parameters = [
            "q": city,
            "appid": APIConfig.openWeatherAPIKey,
            "units": "metric"
        ]
        return try await request("\(APIConfig.baseURL)/weather", parameters: parameters)
    }

    func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let parameters: Parameters = [
            "lat": latitude,
            "lon": longitude,
            "appid": APIConfig.openWeatherAPIKey,
            "units": "metric"
        ]
        return try await request("\(APIConfig.baseURL)/weather", parameters: parameters)
    }

    func fetchForecast(latitude: Double, longitude: Double) async throws -> ForecastResponse {
        let parameters: Parameters = [
            "lat": latitude,
            "lon": longitude,
            "appid": APIConfig.openWeatherAPIKey,
            "units": "metric"
        ]
        return try await request("\(APIConfig.baseURL)/forecast", parameters: parameters)
    }

    private func request<T: Decodable>(_ url: String, parameters: Parameters) async throws -> T {
        do {
            return try await session
                .request(url, parameters: parameters)
                .validate()
                .serializingDecodable(T.self)
                .value
        } catch let afError as AFError {
            if let statusCode = afError.responseCode, statusCode == 404 {
                throw WeatherServiceError.invalidCity
            }
            throw WeatherServiceError.network(afError.localizedDescription)
        } catch {
            throw WeatherServiceError.network(error.localizedDescription)
        }
    }
}
