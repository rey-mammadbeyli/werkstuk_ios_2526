import Foundation
import CoreData

extension CachedWeather {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedWeather> {
        NSFetchRequest<CachedWeather>(entityName: "CachedWeather")
    }

    @NSManaged public var cityName: String?
    @NSManaged public var temperature: Double
    @NSManaged public var feelsLike: Double
    @NSManaged public var weatherDescription: String?
    @NSManaged public var iconCode: String?
    @NSManaged public var humidity: Int32
    @NSManaged public var pressure: Int32
    @NSManaged public var windSpeed: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var isCurrentLocation: Bool
}

extension CachedWeather: Identifiable {}
