import SwiftUI

enum FablePalette {
    static let paper = Color(red: 0.97, green: 0.96, blue: 0.93)
    static let card = Color(red: 1.00, green: 0.99, blue: 0.97)
    static let ink = Color(red: 0.16, green: 0.27, blue: 0.24)
    static let muted = Color(red: 0.43, green: 0.47, blue: 0.43)
    static let accent = Color(red: 0.72, green: 0.45, blue: 0.22)
    static let line = Color(red: 0.87, green: 0.87, blue: 0.82)
    static let softGreen = Color(red: 0.86, green: 0.90, blue: 0.84)
}

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { TodayView() }
                .tabItem { Label("今日", systemImage: "sun.max") }
                .tag(0)
            NavigationStack { StoryLibraryView() }
                .tabItem { Label("故事", systemImage: "books.vertical") }
                .tag(1)
            NavigationStack { LearningProfileView() }
                .tabItem { Label("我的", systemImage: "square.grid.2x2") }
                .tag(2)
        }
        .tint(FablePalette.ink)
        #if DEBUG
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("--preview-library") { selectedTab = 1 }
            if ProcessInfo.processInfo.arguments.contains("--preview-profile") { selectedTab = 2 }
        }
        #endif
    }
}

struct StoryCoverView: View {
    let story: FableStory

    var body: some View {
        Image(story.coverAssetName)
            .resizable()
            .scaledToFill()
            .accessibilityLabel("\(story.title)的封面插画")
    }
}

#Preview {
    ContentView()
        .environmentObject(LearningStore())
}
