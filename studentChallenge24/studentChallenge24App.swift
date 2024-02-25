import SwiftUI
import SwiftData

@main
struct studentChallenge24App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Feelinginfo.self])
    }
}
