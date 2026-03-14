import SwiftUI

@main
struct CleanlinkApp: App {
    @StateObject private var viewModel = CleanlinkViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
