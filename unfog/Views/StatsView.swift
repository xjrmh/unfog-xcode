import SwiftUI
import MapKit
import Combine

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    heroCard
                    monthlyStats
                    altitudeBands
                    topPeaks
                }
                .padding()
            }
            .navigationTitle("Stats")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 200)
                .overlay(
                    Image(systemName: "map")
                        .font(.system(size: 120))
                        .foregroundStyle(Color.white.opacity(0.15))
                        .offset(x: 80, y: -40), alignment: .topTrailing
                )

            VStack(alignment: .leading, spacing: 8) {
                Text("Total distance")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Text(viewModel.totalDistance)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                HStack(spacing: 24) {
                    statPair(title: "Elevation", value: viewModel.totalGain)
                    statPair(title: "Highest", value: viewModel.highestPoint)
                }
            }
            .padding()
        }
    }

    private func statPair(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
        }
    }

    private var monthlyStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This month")
                .font(.headline)
            HStack(spacing: 12) {
                ForEach(viewModel.monthlyStats, id: \.title) { stat in
                    VStack(alignment: .leading) {
                        Text(stat.title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(stat.value)
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
    }

    private var altitudeBands: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Altitude bands")
                .font(.headline)
            VStack(spacing: 12) {
                ForEach(viewModel.altitudeBands) { band in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(band.label)
                            Spacer()
                            Text(band.duration)
                                .foregroundStyle(.secondary)
                        }
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: band.colors, startPoint: .leading, endPoint: .trailing))
                            .frame(height: 12)
                            .overlay(
                                GeometryReader { proxy in
                                    Capsule()
                                        .fill(Color.white.opacity(0.4))
                                        .frame(width: proxy.size.width * CGFloat(band.percentage))
                                }
                            )
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
    }

    private var topPeaks: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top peaks")
                .font(.headline)
            VStack(spacing: 1) {
                ForEach(viewModel.topPeaks) { peak in
                    HStack {
                        Image(systemName: "triangle")
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading) {
                            Text(peak.name)
                            Text(peak.location)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(peak.altitude)
                            .font(.body.weight(.semibold))
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

final class StatsViewModel: ObservableObject {
    struct MonthlyStat: Identifiable {
        let id = UUID()
        let title: String
        let value: String
    }

    struct AltitudeBand: Identifiable {
        let id = UUID()
        let label: String
        let duration: String
        let percentage: Double
        let colors: [Color]
    }

    struct Peak: Identifiable {
        let id = UUID()
        let name: String
        let location: String
        let altitude: String
    }

    let totalDistance = "128 km"
    let totalGain = "+3,820 m"
    let highestPoint = "3,210 m"

    let monthlyStats: [MonthlyStat] = [
        .init(title: "Distance", value: "44 km"),
        .init(title: "Gain", value: "+980 m"),
        .init(title: "Moving", value: "6h 42m")
    ]

    let altitudeBands: [AltitudeBand] = [
        .init(label: "0-500 m", duration: "1h 24m", percentage: 0.7, colors: [.blue, .green]),
        .init(label: "500-1000 m", duration: "52m", percentage: 0.5, colors: [.green, .yellow]),
        .init(label: ">1000 m", duration: "38m", percentage: 0.3, colors: [.orange, .red])
    ]

    let topPeaks: [Peak] = [
        .init(name: "Mt. Solace", location: "California", altitude: "2,942 m"),
        .init(name: "Echo Ridge", location: "Nevada", altitude: "2,112 m"),
        .init(name: "Cloud Rest", location: "Colorado", altitude: "3,845 m")
    ]
}

#Preview("Stats Light") {
    StatsView()
        .preferredColorScheme(.light)
}

#Preview("Stats Dark") {
    StatsView()
        .preferredColorScheme(.dark)
}
