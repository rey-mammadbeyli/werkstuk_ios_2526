import SwiftUI

/// Renders a weather condition icon using SF Symbols, mapped from
/// OpenWeather's icon codes (e.g. "01d", "10n").
struct WeatherIconView: View {
    let iconCode: String
    var size: CGFloat = 60

    var body: some View {
        Image(systemName: symbolName)
            .resizable()
            .scaledToFit()
            .symbolRenderingMode(.multicolor)
            .frame(width: size, height: size)
    }

    private var symbolName: String {
        switch iconCode {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.stars.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "smoke.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.rain.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "questionmark.circle"
        }
    }
}

#Preview {
    WeatherIconView(iconCode: "01d")
}
