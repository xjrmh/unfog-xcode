import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            MapScreen()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#Preview("Light") {
    RootTabView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    RootTabView()
        .preferredColorScheme(.dark)
}
