import Foundation
import CoreLocation
import Combine

/// Single source of truth for the weather screens. Coordinates between
/// LocationManager (GPS), WeatherService (API), PersistenceController
/// (Core Data cache) and NetworkMonitor (offline detection).
@MainActor
final class WeatherViewModel: ObservableObject {
    // Home screen
    @Published var currentWeather: WeatherDisplayData?
    @Published var forecast: [ForecastResponse.ForecastEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOffline = false
    @Published var lastUpdated: Date?

    // Search screen
    @Published var searchResults: WeatherDisplayData?
    @Published var savedCities: [WeatherDisplayData] = []
    @Published var fullForecast: [ForecastResponse.ForecastEntry] = []

    var dailyForecast: [DailyForecast] {
            DailyForecast.group(from: fullForecast)
    }
    private let weatherService = WeatherService.shared
    private let persistence = PersistenceController.shared
    let locationManager = LocationManager()
    private let networkMonitor = NetworkMonitor.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                self?.isOffline = !connected
            }
            .store(in: &cancellables)

        locationManager.$location
            .compactMap { $0 }
            // Avoid re-fetching for tiny GPS jitter.
            .removeDuplicates { old, new in old.distance(from: new) < 500 }
            .sink { [weak self] location in
                Task { await self?.loadWeather(for: location) }
            }
            .store(in: &cancellables)

        loadCachedWeatherIfNeeded()
        loadSavedCities()
    }


    /// Loads the last cached reading immediately so the Home screen never
    /// shows a blank state while the network call is in flight.
    private func loadCachedWeatherIfNeeded() {
        if let cached = persistence.lastCurrentLocationWeather() ?? persistence.mostRecentWeather() {
            currentWeather = cached
            lastUpdated = cached.lastUpdated
        }
    }

    func onAppear() {
        if currentWeather == nil {
            locationManager.requestLocation()
        }
    }


    func refreshCurrentLocation() {
        locationManager.requestLocation()
    }

    private func loadWeather(for location: CLLocation) async {
        guard networkMonitor.isConnected else {
            isOffline = true
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await weatherService.fetchCurrentWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            let data = WeatherDisplayData.from(response: response)
            currentWeather = data
            lastUpdated = data.lastUpdated
            isOffline = false
            persistence.saveWeather(data, isCurrentLocation: true)
            loadSavedCities()
            await loadForecast(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        } catch {
            handleFailure(error: error, fallbackCity: nil)
        }
    }


    func searchCity(_ city: String) async {
        let trimmed = city.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        guard networkMonitor.isConnected else {
            isOffline = true
            searchResults = persistence.lastWeather(forCity: trimmed)
            errorMessage = searchResults == nil
                ? "No internet connection and no cached data for \"\(trimmed)\"."
                : nil
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await weatherService.fetchCurrentWeather(city: trimmed)
            let data = WeatherDisplayData.from(response: response)
            searchResults = data
            isOffline = false
            persistence.saveWeather(data, isCurrentLocation: false)
            loadSavedCities()
            await loadForecast(latitude: data.latitude, longitude: data.longitude)
        } catch {
            handleFailure(error: error, fallbackCity: trimmed)
        }
    }

    /// Lets the user promote a searched city to be shown on the Home screen.
    func selectSearchResultAsCurrent() {
        guard let searchResults else { return }
        currentWeather = searchResults
        lastUpdated = searchResults.lastUpdated
    }


    private func loadForecast(latitude: Double, longitude: Double) async {
            do {
                let response = try await weatherService.fetchForecast(latitude: latitude, longitude: longitude)
                fullForecast = response.list
                forecast = Array(response.list.prefix(8)) // next ~24h in 3h steps
            } catch {
                print("Failed to load forecast: \(error)")
            }
        }


    private func handleFailure(error: Error, fallbackCity: String?) {
        if let cachedFallback = fallbackCity.flatMap({ persistence.lastWeather(forCity: $0) }) ?? persistence.mostRecentWeather() {
            if let fallbackCity {
                _ = fallbackCity // fallback resolved for the search screen
                searchResults = cachedFallback
            } else {
                currentWeather = cachedFallback
                lastUpdated = cachedFallback.lastUpdated
            }
            isOffline = true
        }

        errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
    }
    

        func loadSavedCities() {
            savedCities = persistence.allCachedWeather()
        }

        func deleteCity(_ city: WeatherDisplayData) {
            persistence.deleteWeather(forCity: city.cityName)
            loadSavedCities()
        }
}
