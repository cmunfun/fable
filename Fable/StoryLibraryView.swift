import SwiftUI

struct StoryLibraryView: View {
    @EnvironmentObject private var learningStore: LearningStore
    @State private var searchText = ""
    @State private var selectedTopic: StoryTopic?

    private var filteredStories: [FableStory] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return StoryCatalog.stories.filter { story in
            let topicMatches = selectedTopic.map { story.topics.contains($0) } ?? true
            guard topicMatches else { return false }
            guard !query.isEmpty else { return true }
            return [story.title, story.teaser, story.category, story.concept, story.conceptChinese]
                .contains(where: { $0.localizedStandardContains(query) })
                || story.topics.contains(where: { $0.title.localizedStandardContains(query) })
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("故事")
                    .font(.system(.largeTitle, design: .serif, weight: .semibold))
                    .foregroundStyle(FablePalette.ink)
                    .padding(.top, 28)

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(FablePalette.muted)
                    TextField("搜索故事或概念", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(FablePalette.muted)
                        }
                        .accessibilityLabel("清除搜索")
                    }
                }
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(FablePalette.card, in: RoundedRectangle(cornerRadius: 16))

                topicFilters

                HStack {
                    Text("探索故事")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(FablePalette.ink)
                    Spacer()
                    Text("\(filteredStories.count) 篇")
                        .font(.subheadline)
                        .foregroundStyle(FablePalette.muted)
                }
                .padding(.top, 5)

                if filteredStories.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredStories) { story in
                            NavigationLink {
                                StoryReaderView(story: story, progress: learningStore.progress(for: story.id))
                            } label: {
                                storyRow(story)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .frame(maxWidth: 700, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
            .frame(maxWidth: .infinity)
        }
        .background(FablePalette.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topicFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "全部", selected: selectedTopic == nil) {
                    selectedTopic = nil
                }
                ForEach(StoryTopic.allCases) { topic in
                    filterChip(title: topic.title, selected: selectedTopic == topic) {
                        selectedTopic = topic
                    }
                }
            }
            .padding(.vertical, 3)
        }
        .contentMargins(.trailing, 24)
    }

    private func filterChip(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(selected ? FablePalette.card : FablePalette.ink)
                .padding(.horizontal, 15)
                .padding(.vertical, 9)
                .background(selected ? FablePalette.ink : FablePalette.card, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func storyRow(_ story: FableStory) -> some View {
        let progress = learningStore.progress(for: story.id)
        return HStack(spacing: 16) {
            StoryCoverView(story: story)
                .frame(width: 82, height: 104)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 7) {
                Text(story.topics.map(\.title).joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(FablePalette.accent)
                    .lineLimit(1)
                Text(story.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(FablePalette.ink)
                    .lineLimit(2)
                Text(progress.isComplete ? "已读完 · 可回顾" :
                     progress.hasStarted ? "阅读中 · 可接着读" : "约 \(story.readingMinutes) 分钟")
                    .font(.caption)
                    .foregroundStyle(FablePalette.muted)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(FablePalette.muted)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FablePalette.card, in: RoundedRectangle(cornerRadius: 20))
    }
}
