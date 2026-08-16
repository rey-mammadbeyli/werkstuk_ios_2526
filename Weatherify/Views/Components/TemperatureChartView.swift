import SwiftUI
import Charts

/// Line chart showing the temperature forecast (next ~24h, 3h steps).
struct TemperatureChartView: View {
    let entries: [ForecastResponse.ForecastEntry]

    var body: some View {
        if entries.isEmpty {
            EmptyView()
        } else {
            Chart(entries) { entry in
                LineMark(
                    x: .value("Time", entry.date),
                    y: .value("Temperature", entry.main.temp)
                )
                .interpolationMethod(.catmullRom)
                .symbol(.circle)
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .frame(height: 180)
            .padding(.vertical, 8)
        }
    }
}
