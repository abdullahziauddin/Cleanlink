import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CleanlinkViewModel()
    @State private var isSplashing = true
    
    var body: some View {
        Group {
            if isSplashing {
                SplashView(isSplashing: $isSplashing)
            } else if !viewModel.hasSeenOnboarding {
                OnboardingView()
                    .environmentObject(viewModel)
            } else {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Clean", systemImage: "link")
                        }
                    
                    HistoryView()
                        .tabItem {
                            Label("History", systemImage: "clock.fill")
                        }
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
                .accentColor(Theme.Colors.primary)
                .environmentObject(viewModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
