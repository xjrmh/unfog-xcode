import SwiftUI
import MapKit

struct MapScreen: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .top) {
            mapLayer
                .ignoresSafeArea()

            VStack(spacing: 12) {
                topBar
                modePicker
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 20)

            VStack {
                Spacer()
                bottomSheet
            }

            VStack {
                Spacer()
                floatingButtons
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing)
            .padding(.bottom, 160)

            VStack {
                Spacer()
                altitudeLegend
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .bottom], 24)
            }
        }
        .onAppear {
            viewModel.requestPermissionIfNeeded()
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                ProfileView()
            }
        }
    }

    private var mapLayer: some View {
        Map(coordinateRegion: $viewModel.region,
            showsUserLocation: true,
            annotationItems: viewModel.samples) { sample in
            MapAnnotation(coordinate: sample.coordinate) {
                Circle()
                    .fill(viewModel.displayMode == .altitude ? viewModel.color(for: sample.altitude) : Color.accentColor.opacity(0.8))
                    .frame(width: viewModel.displayMode == .altitude ? 12 : 8,
                           height: viewModel.displayMode == .altitude ? 12 : 8)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.8), lineWidth: 1)
                    )
            }
        }
        .mapStyle(.standard(elevation: .realistic))
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            avatar
            VStack(alignment: .leading, spacing: 2) {
                Text("Unfog")
                    .font(.headline)
                Text("Altitude explorer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .imageScale(.large)
                    .padding(8)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        .padding(.horizontal)
    }

    private var avatar: some View {
        Text("L")
            .font(.headline)
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(Circle().fill(Color.blue))
    }

    private var modePicker: some View {
        Picker("Mode", selection: $viewModel.displayMode) {
            ForEach(MapViewModel.DisplayMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var floatingButtons: some View {
        VStack(spacing: 12) {
            floatingButton(systemName: "location.fill") {
                viewModel.recenter()
            }
            floatingButton(systemName: "scope") {
                // adjust heading / compass
            }
            floatingButton(systemName: viewModel.isRecording ? "stop.circle.fill" : "record.circle") {
                viewModel.toggleRecording()
            }
            floatingButton(systemName: "map") {
                // toggle map style placeholder
            }
        }
    }

    private func floatingButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .imageScale(.large)
                .foregroundStyle(.primary)
                .padding()
        }
        .background(.ultraThinMaterial)
        .clipShape(Circle())
        .shadow(radius: 4)
    }

    private var bottomSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Capsule()
                .fill(Color.secondary.opacity(0.6))
                .frame(width: 40, height: 5)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.headline)
                Text("San Francisco Bay")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                StatPill(title: "Time", value: "3h 12m")
                StatPill(title: "+Gain", value: "+842 m")
                StatPill(title: "Max", value: "1,942 m")
            }

            AltitudeSparkline(samples: viewModel.samples, gradient: viewModel.legendGradient())
                .frame(height: 80)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .padding()
    }

    private var altitudeLegend: some View {
        HStack(spacing: 12) {
            LinearGradient(gradient: viewModel.legendGradient(), startPoint: .leading, endPoint: .trailing)
                .frame(width: 120, height: 10)
                .clipShape(Capsule())
            VStack(alignment: .leading) {
                Text("Low")
                    .font(.caption2)
                Text("High")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(radius: 4)
    }
}

struct StatPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct AltitudeSparkline: View {
    let samples: [LocationSample]
    let gradient: Gradient

    var body: some View {
        GeometryReader { proxy in
            let points = normalizedPoints(in: proxy.size)
            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                points.dropFirst().forEach { path.addLine(to: $0) }
            }
            .stroke(LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground).opacity(0.7))
            )
        }
    }

    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard let minAltitude = samples.map({ $0.altitude }).min(),
              let maxAltitude = samples.map({ $0.altitude }).max(),
              maxAltitude > minAltitude else {
            return [CGPoint(x: 0, y: size.height / 2), CGPoint(x: size.width, y: size.height / 2)]
        }
        let range = maxAltitude - minAltitude
        return samples.enumerated().map { index, sample in
            let x = size.width * CGFloat(Double(index) / Double(samples.count - 1))
            let normalized = (sample.altitude - minAltitude) / range
            let y = size.height * (1 - CGFloat(normalized))
            return CGPoint(x: x, y: y)
        }
    }
}

#Preview("Map Light") {
    MapScreen()
        .preferredColorScheme(.light)
}

#Preview("Map Dark") {
    MapScreen()
        .preferredColorScheme(.dark)
}
