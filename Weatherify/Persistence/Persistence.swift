import CoreData
import Foundation

/// Owns the Core Data stack and provides simple, typed helpers for reading
/// and writing the single CachedWeather entity used for offline fallback.
final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Weatherify")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var context: NSManagedObjectContext { container.viewContext }

    // MARK: - Save

    /// Inserts or updates the cached row for a given city.
    func saveWeather(_ weather: WeatherDisplayData, isCurrentLocation: Bool) {
        let request: NSFetchRequest<CachedWeather> = CachedWeather.fetchRequest()
        request.predicate = NSPredicate(format: "cityName ==[c] %@", weather.cityName)

        let cached = (try? context.fetch(request))?.first ?? CachedWeather(context: context)

        cached.cityName = weather.cityName
        cached.temperature = weather.temperature
        cached.feelsLike = weather.feelsLike
        cached.weatherDescription = weather.description
        cached.iconCode = weather.iconCode
        cached.humidity = Int32(weather.humidity)
        cached.pressure = Int32(weather.pressure)
        cached.windSpeed = weather.windSpeed
        cached.latitude = weather.latitude
        cached.longitude = weather.longitude
        cached.lastUpdated = weather.lastUpdated
        cached.isCurrentLocation = isCurrentLocation

        do {
            try context.save()
        } catch {
            print("Failed to save weather to Core Data: \(error)")
        }
    }

    // MARK: - Fetch

    /// The most recently cached reading that was tied to the user's GPS location.
    func lastCurrentLocationWeather() -> WeatherDisplayData? {
        let request: NSFetchRequest<CachedWeather> = CachedWeather.fetchRequest()
        request.predicate = NSPredicate(format: "isCurrentLocation == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "lastUpdated", ascending: false)]
        request.fetchLimit = 1
        return (try? context.fetch(request))?.first.map(map)
    }

    /// The cached reading for a specific, manually searched city.
    func lastWeather(forCity city: String) -> WeatherDisplayData? {
        let request: NSFetchRequest<CachedWeather> = CachedWeather.fetchRequest()
        request.predicate = NSPredicate(format: "cityName ==[c] %@", city)
        request.fetchLimit = 1
        return (try? context.fetch(request))?.first.map(map)
    }

    /// Whatever was cached most recently, regardless of source. Used as a
    /// last resort fallback on first launch without connectivity.
    func mostRecentWeather() -> WeatherDisplayData? {
        let request: NSFetchRequest<CachedWeather> = CachedWeather.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "lastUpdated", ascending: false)]
        request.fetchLimit = 1
        return (try? context.fetch(request))?.first.map(map)
    }
    
    /// All cached cities, most recently updated first. Powers the Cities tab.
        func allCachedWeather() -> [WeatherDisplayData] {
            let request: NSFetchRequest<CachedWeather> = CachedWeather.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "lastUpdated", ascending: false)]
            return ((try? context.fetch(request)) ?? []).map(map)
        }
    
    
    // Removes a cached city entirely (used when the user deletes it from the Cities list).
        func deleteWeather(forCity city: String) {
            let request: NSFetchRequest<CachedWeather> = CachedWeather.fetchRequest()
            request.predicate = NSPredicate(format: "cityName ==[c] %@", city)
            if let results = try? context.fetch(request) {
                results.forEach(context.delete)
                try? context.save()
            }
        }
    
    

    private func map(_ cached: CachedWeather) -> WeatherDisplayData {
        WeatherDisplayData(
            cityName: cached.cityName ?? "-",
            temperature: cached.temperature,
            feelsLike: cached.feelsLike,
            description: cached.weatherDescription ?? "-",
            iconCode: cached.iconCode ?? "01d",
            humidity: Int(cached.humidity),
            pressure: Int(cached.pressure),
            windSpeed: cached.windSpeed,
            latitude: cached.latitude,
            longitude: cached.longitude,
            lastUpdated: cached.lastUpdated ?? Date()
        )
    }
}
