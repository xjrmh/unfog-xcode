import SwiftUI

struct ProfileView: View {
    @State private var autoRecord = true
    @State private var preciseLocation = true
    @State private var distanceUnit = 0
    @State private var altitudeUnit = 0
    @State private var storeOnDevice = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 56, height: 56)
                            .overlay(Text("L").font(.title).foregroundStyle(.white))
                        VStack(alignment: .leading) {
                            Text("Lumen Traveler")
                                .font(.headline)
                            Text("Always exploring")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Tracking") {
                    Toggle("Auto record in background", isOn: $autoRecord)
                    Toggle("Use precise location", isOn: $preciseLocation)
                }

                Section("Units") {
                    Picker("Distance", selection: $distanceUnit) {
                        Text("Kilometers").tag(0)
                        Text("Miles").tag(1)
                    }
                    Picker("Altitude", selection: $altitudeUnit) {
                        Text("Meters").tag(0)
                        Text("Feet").tag(1)
                    }
                }

                Section("Data") {
                    Button {
                        // Export GPX placeholder
                        print("Exporting GPX")
                    } label: {
                        Label("Export GPX", systemImage: "square.and.arrow.up")
                    }
                    Button(role: .destructive) {
                        // Clear history placeholder
                    } label: {
                        Label("Clear history", systemImage: "trash")
                    }
                }

                Section("Privacy") {
                    Toggle("Store data only on device", isOn: $storeOnDevice)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview("Profile Light") {
    ProfileView()
        .preferredColorScheme(.light)
}

#Preview("Profile Dark") {
    ProfileView()
        .preferredColorScheme(.dark)
}
