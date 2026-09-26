import SwiftUI

@main
struct FableApp: App {
    @StateObject private var learningStore = LearningStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(learningStore)
        }
    }
}
