import SwiftUI

/// Clear, visible indicator shown whenever the app is displaying cached
/// (rather than live) data because there is no internet connection.
struct OfflineBannerView: View {
    let lastUpdated: Date?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
            Text(message)
                .font(.footnote)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.15))
        .foregroundStyle(.orange)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var message: String {
        if let lastUpdated {
            return "You're offline. Showing data from \(lastUpdated.formatted(date: .abbreviated, time: .shortened))."
        }
        return "You're offline. No cached weather data is available yet."
    }
}
