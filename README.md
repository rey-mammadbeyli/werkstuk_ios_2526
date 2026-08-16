# Weatherify 🌤️

An iOS weather app built with SwiftUI that shows current conditions and multi-day forecasts based on the user's location or a manually searched city — with offline fallback backed by Core Data, and a persistent multi-city dashboard on a map.

Built for IOS as a demonstration of MVVM architecture, REST API integration, on-device persistence, and CoreLocation/MapKit usage in a real-world iOS app.

---

## Features

- *Home tab* — current weather (temperature, description, icon) for the user's GPS location, with a color-themed gradient background that changes based on conditions, plus quick-stat pills for "feels like," humidity, and wind.
- *Cities tab* — a saved list of every city you've looked up, with swipe-to-delete and quick access to each one's detail view.
- *Forecast tab* — a multi-day forecast (aggregated from OpenWeather's 3-hour-step data) for whichever city is currently active.
- *Map tab* — MapKit view showing every saved city as a pin, with tap-to-preview weather detail.
- *Search* — manually look up any city's weather, independent of GPS.
- *Detail screen* — humidity, pressure, wind speed, coordinates, and a temperature-over-time line chart (Swift Charts) for the next 24 hours.
- *Offline fallback* — the most recently fetched reading for each city is cached in Core Data and shown (with a clear "You're offline" banner) whenever there's no internet connection, including on first launch before any network call has completed.
- *Last updated timestamp* — always visible on the Home screen.
- *Manual + first-launch refresh* — pull the latest data on demand via the refresh button; data is also fetched automatically on first launch.

---

## Architecture (MVVM)
Weatherify/
├── App/
│ └── WeatherifyApp.swift entry point (@main)
├── Models/
│ ├── WeatherResponse.swift Codable: OpenWeather /weather response
│ ├── ForecastResponse.swift Codable: OpenWeather /forecast response
│ ├── WeatherDisplayData.swift UI-facing domain model
│ └── DailyForecast.swift aggregated multi-day forecast model
├── ViewModels/
│ └── WeatherViewModel.swift all business logic + shared state
├── Views/
│ ├── RootTabView.swift 4-tab root container
│ ├── HomeView.swift
│ ├── CitiesView.swift
│ ├── ForecastView.swift
│ ├── MapTabView.swift
│ ├── SearchView.swift
│ ├── DetailView.swift
│ └── Components/
│ ├── WeatherIconView.swift
│ ├── TemperatureChartView.swift
│ └── OfflineBannerView.swift
├── Services/
│ ├── WeatherService.swift networking (Alamofire)
│ ├── LocationManager.swift CoreLocation wrapper
│ └── NetworkMonitor.swift connectivity (Network framework)
├── Persistence/
│ ├── Weatherify.xcdatamodeld Core Data model (CachedWeather entity)
│ ├── CachedWeather+CoreDataClass.swift
│ ├── CachedWeather+CoreDataProperties.swift
│ └── Persistence.swift Core Data stack + save/fetch helpers
└── Config/
└── APIConfig.swift API key + base URL


- *Model* — WeatherResponse / ForecastResponse (raw OpenWeather payloads), WeatherDisplayData (the shape Views consume), DailyForecast (aggregated per-day summary), and the CachedWeather Core Data entity for offline storage.
- *View* — plain SwiftUI views that only read @Published state from the ViewModel and call its methods; no business logic lives in the Views.
- *ViewModel* — WeatherViewModel talks to WeatherService, LocationManager, NetworkMonitor, and PersistenceController, and exposes a single, simple state surface shared across all four tabs via @EnvironmentObject.

---

## Tech stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Language | Swift |
| Location | CoreLocation |
| Map | MapKit |
| Local storage | Core Data |
| Networking | URLSession, wrapped by *Alamofire* (external library) |
| Visualization | Swift Charts, SF Symbols |
| Web service | [OpenWeather API](https://openweathermap.org/api) (current weather + 5-day/3-hour forecast) |

---

## Setup

1. Clone this repository and open Weatherify.xcodeproj in Xcode.
2. Add *Alamofire* via Swift Package Manager if not already resolved:
   File → Add Package Dependencies… → https://github.com/Alamofire/Alamofire → add the *Alamofire* product (not AlamofireDynamic) to the Weatherify target.
3. Get a free API key at [openweathermap.org/api](https://openweathermap.org/api) and paste it into Config/APIConfig.swift (openWeatherAPIKey).
4. Build & run on an iPhone simulator or device (iOS 17+ required, for Swift Charts and MapKit's modern Map API).

On first launch, allow the location permission prompt so the Home tab can fetch weather for your current position.

---


*Extras beyond the original requirements:*
- A *Cities tab* with a persistent, swipe-to-delete list of every searched city.
- A *Forecast tab* with a proper multi-day (not just 24h) forecast view.
- A colorful, condition-aware gradient theme on the Home screen with quick-stat pills.

---


## Author

Built by Rey Mammadbeyli, 2026.
