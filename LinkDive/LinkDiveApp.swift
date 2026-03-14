import SwiftUI

@main
struct LinkDiveApp: App {
    @StateObject private var viewModel = LinkDiveViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
