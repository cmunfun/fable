import SwiftUI

struct LearningProfileView: View {
    @EnvironmentObject private var learningStore: LearningStore

    private var completedStories: [FableStory] {
        StoryCatalog.stories
            .filter { learningStore.progress(for: $0.id).isComplete }
            .sorted {
                (learningStore.progress(for: $0.id).completedAt ?? .distantPast)
                > (learningStore.progress(for: $1.id).completedAt ?? .distantPast)
            }
    }
    private var learnedConceptStories: [FableStory] {
        var seen = Set<String>()
        return completedStories.filter { seen.insert($0.concept).inserted }
    }
    private var reviewStories: [FableStory] {
        completedStories.sorted {
            let left = learningStore.progress(for: $0.id)
            let right = learningStore.progress(for: $1.id)
            if left.isDue != right.isDue { return left.isDue }
            return (left.nextReviewAt ?? .distantFuture) < (right.nextReviewAt ?? .distantFuture)
        }
    }
    private var dueCount: Int { reviewStories.filter { learningStore.progress(for: $0.id).isDue }.count }
    private var savedCount: Int {
        StoryCatalog.stories.filter { learningStore.progress(for: $0.id).isSaved }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    Text("我的")
                        .font(.system(.largeTitle, design: .serif, weight: .semibold))
                        .foregroundStyle(FablePalette.ink)
                    Spacer()
                    NavigationLink {
                        FableSettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundStyle(FablePalette.ink)
                            .frame(width: 44, height: 44)
                            .background(FablePalette.card, in: Circle())
                    }
                    .accessibilityLabel("设置")
                }
                .padding(.top, 28)

                HStack(spacing: 12) {
                    metric(value: learnedConceptStories.count, label: "已学概念")
                    metric(value: dueCount, label: "待复习")
                }

                ActivityHeatmapView(events: learningStore.events)

                sectionHeader("回想一下", destination: ReviewQueueView(), action: "全部复习", showAction: !reviewStories.isEmpty)
                if reviewStories.isEmpty {
                    emptyState("完成第一篇故事后，这里会出现复习卡片。")
                } else {
                    VStack(spacing: 10) {
                        ForEach(Array(reviewStories.prefix(3))) { story in
                            NavigationLink {
                                StoryReviewView(story: story)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(story.title)
                                            .font(.headline)
                                            .foregroundStyle(FablePalette.ink)
                                        Text(learningStore.progress(for: story.id).isDue ? "今天该复习" : "随时练习")
                                            .font(.caption)
                                            .foregroundStyle(FablePalette.muted)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .foregroundStyle(FablePalette.ink)
                                }
                                .padding(18)
                                .background(FablePalette.card, in: RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                ThinkingTendencyView(stories: StoryCatalog.stories)

                sectionHeader("最近学到", destination: ProfileCollectionView(mode: .learned), action: "全部概念", showAction: !learnedConceptStories.isEmpty)
                if learnedConceptStories.isEmpty {
                    emptyState("读完故事后，概念会收在这里。")
                } else {
                    VStack(spacing: 10) {
                        ForEach(Array(learnedConceptStories.prefix(2))) { story in
                            NavigationLink {
                                StoryReaderView(story: story, progress: learningStore.progress(for: story.id), openAtInsight: true)
                            } label: {
                                HStack {
                                    Text(story.conceptChinese)
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                }
                                .foregroundStyle(FablePalette.ink)
                                .padding(18)
                                .background(FablePalette.card, in: RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                NavigationLink {
                    ProfileCollectionView(mode: .saved)
                } label: {
                    HStack {
                        Image(systemName: "bookmark")
                        Text("我的收藏")
                        Spacer()
                        Text("\(savedCount)")
                            .foregroundStyle(FablePalette.muted)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FablePalette.ink)
                    .padding(18)
                    .background(FablePalette.card, in: RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: 700, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 38)
            .frame(maxWidth: .infinity)
        }
        .background(FablePalette.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func metric(value: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(value)")
                .font(.system(.title, design: .serif, weight: .semibold))
                .foregroundStyle(FablePalette.ink)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(FablePalette.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(19)
        .background(FablePalette.card, in: RoundedRectangle(cornerRadius: 20))
    }

    private func sectionHeader<Destination: View>(
        _ title: String,
        destination: Destination,
        action: String,
        showAction: Bool
    ) -> some View {
        HStack {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(FablePalette.ink)
            Spacer()
            if showAction {
                NavigationLink(action) { destination }
                    .font(.subheadline)
                    .foregroundStyle(FablePalette.accent)
            }
        }
    }

    private func emptyState(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(FablePalette.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(FablePalette.card, in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct ActivityHeatmapView: View {
    let events: [LearningEvent]
    private let calendar = Calendar.current
    private let weeks = 52

    private var today: Date { calendar.startOfDay(for: .now) }
    private var firstDay: Date {
        let currentWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        return calendar.date(byAdding: .weekOfYear, value: -(weeks - 1), to: currentWeek) ?? today
    }
    private var counts: [Date: Int] {
        Dictionary(grouping: events, by: { calendar.startOfDay(for: $0.occurredAt) })
            .mapValues(\.count)
    }
    private var activeDays: Int {
        counts.filter { $0.key >= firstDay && $0.key <= today && $0.value > 0 }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("学习活跃度")
                    .font(.headline)
                    .foregroundStyle(FablePalette.ink)
                Spacer()
                Text("近一年 · \(activeDays) 天")
                    .font(.caption)
                    .foregroundStyle(FablePalette.muted)
            }

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(0..<weeks, id: \.self) { week in
                            VStack(spacing: 4) {
                                ForEach(0..<7, id: \.self) { weekday in
                                    heatCell(week: week, weekday: weekday)
                                }
                            }
                            .id(week)
                        }
                    }
                }
                .onAppear {
                    proxy.scrollTo(weeks - 1, anchor: .trailing)
                }
            }

            HStack {
                Text("完成故事或复习一次，记一次学习")
                    .font(.caption)
                    .foregroundStyle(FablePalette.muted)
                Spacer()
                Text("少")
                    .foregroundStyle(FablePalette.muted)
                RoundedRectangle(cornerRadius: 3)
                    .fill(FablePalette.softGreen)
                    .frame(width: 11, height: 11)
                RoundedRectangle(cornerRadius: 3)
                    .fill(FablePalette.ink)
                    .frame(width: 11, height: 11)
                Text("多")
                    .foregroundStyle(FablePalette.muted)
            }
            .font(.caption2)
        }
        .padding(20)
        .background(FablePalette.card, in: RoundedRectangle(cornerRadius: 22))
    }

    @ViewBuilder
    private func heatCell(week: Int, weekday: Int) -> some View {
        let offset = week * 7 + weekday
        let date = calendar.date(byAdding: .day, value: offset, to: firstDay) ?? today
        let count = counts[date] ?? 0
        RoundedRectangle(cornerRadius: 3)
            .fill(date > today ? Color.clear : color(for: count))
            .frame(width: 15, height: 15)
            .accessibilityLabel("\(date.formatted(date: .abbreviated, time: .omitted))，\(count) 次学习")
    }

    private func color(for count: Int) -> Color {
        switch count {
        case 0: FablePalette.line.opacity(0.65)
        case 1: FablePalette.softGreen
        case 2: Color(red: 0.61, green: 0.75, blue: 0.62)
        case 3: Color(red: 0.37, green: 0.58, blue: 0.42)
        default: FablePalette.ink
        }
    }
}

private struct ThinkingTendencyView: View {
    @EnvironmentObject private var learningStore: LearningStore
    let stories: [FableStory]

    private var completedCount: Int {
        stories.filter { learningStore.progress(for: $0.id).isComplete }.count
    }
    private var scores: [(topic: StoryTopic, score: Int)] {
        StoryTopic.allCases.map { topic in
            let score = stories.filter { $0.topics.contains(topic) }.reduce(0) { total, story in
                let progress = learningStore.progress(for: story.id)
                return total + (progress.isComplete ? 2 : 0) + (progress.isSaved ? 1 : 0)
            }
            return (topic, score)
        }
        .filter { $0.score > 0 }
        .sorted { $0.score > $1.score }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("思考倾向")
                    .font(.headline)
                Spacer()
                Image(systemName: "sparkle")
                    .foregroundStyle(FablePalette.accent)
            }
            .foregroundStyle(FablePalette.ink)

            if completedCount < 3 {
                Text("再读 \(3 - completedCount) 篇，才有足够记录观察你常关注的主题。")
                    .font(.subheadline)
                    .foregroundStyle(FablePalette.muted)
            } else if let first = scores.first {
                Text("你近期更常关注「\(first.topic.title)」。")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(FablePalette.ink)
                ForEach(Array(scores.prefix(3)), id: \.topic) { item in
                    HStack(spacing: 12) {
                        Text(item.topic.title)
                            .font(.caption)
                            .frame(width: 66, alignment: .leading)
                        ProgressView(value: Double(item.score), total: Double(max(scores.first?.score ?? 1, 1)))
                            .tint(FablePalette.ink)
                    }
                    .foregroundStyle(FablePalette.muted)
                }
                Text("依据已读和收藏的主题估算，会随你的选择变化。")
                    .font(.caption)
                    .foregroundStyle(FablePalette.muted)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FablePalette.card, in: RoundedRectangle(cornerRadius: 22))
    }
}

private struct ReviewQueueView: View {
    @EnvironmentObject private var learningStore: LearningStore

    private var stories: [FableStory] {
        StoryCatalog.stories
            .filter { learningStore.progress(for: $0.id).isComplete }
            .sorted {
                (learningStore.progress(for: $0.id).nextReviewAt ?? .distantFuture)
                < (learningStore.progress(for: $1.id).nextReviewAt ?? .distantFuture)
            }
    }

    var body: some View {
        List(stories) { story in
            NavigationLink {
                StoryReviewView(story: story)
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text(story.title)
                        .font(.headline)
                    Text(learningStore.progress(for: story.id).isDue ? "今天该复习" : "随时练习")
                        .font(.caption)
                        .foregroundStyle(FablePalette.muted)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(FablePalette.paper.ignoresSafeArea())
        .navigationTitle("全部复习")
        .toolbar(.visible, for: .navigationBar)
    }
}

private enum ProfileCollectionMode {
    case learned
    case saved

    var title: String { self == .learned ? "学过的概念" : "我的收藏" }
}

private struct ProfileCollectionView: View {
    @EnvironmentObject private var learningStore: LearningStore
    @State private var searchText = ""
    let mode: ProfileCollectionMode

    private var stories: [FableStory] {
        let matching = StoryCatalog.stories
            .filter {
                let progress = learningStore.progress(for: $0.id)
                let included = mode == .learned ? progress.isComplete : progress.isSaved
                return included && (searchText.isEmpty
                    || $0.title.localizedStandardContains(searchText)
                    || $0.conceptChinese.localizedStandardContains(searchText)
                    || $0.concept.localizedStandardContains(searchText))
            }
            .sorted {
                (learningStore.progress(for: $0.id).completedAt ?? .distantPast)
                > (learningStore.progress(for: $1.id).completedAt ?? .distantPast)
            }
        guard mode == .learned else { return matching }
        var seen = Set<String>()
        return matching.filter { seen.insert($0.concept).inserted }
    }

    var body: some View {
        List(stories) { story in
            NavigationLink {
                StoryReaderView(story: story, progress: learningStore.progress(for: story.id), openAtInsight: true)
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text(story.conceptChinese)
                        .font(.headline)
                    Text(story.title)
                        .font(.subheadline)
                        .foregroundStyle(FablePalette.muted)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(FablePalette.paper.ignoresSafeArea())
        .navigationTitle(mode.title)
        .toolbar(.visible, for: .navigationBar)
        .searchable(text: $searchText, prompt: "搜索概念")
    }
}
