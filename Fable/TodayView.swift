import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var learningStore: LearningStore

    private var story: FableStory { StoryCatalog.today }
    private var progress: StoryProgress { learningStore.progress(for: story.id) }
    private var completedCount: Int {
        Set(StoryCatalog.stories
            .filter { learningStore.progress(for: $0.id).isComplete }
            .map(\.concept)).count
    }
    private var activeDaysThisWeek: Int {
        let calendar = Calendar.current
        guard let week = calendar.dateInterval(of: .weekOfYear, for: .now) else { return 0 }
        return Set(learningStore.events.filter { $0.occurredAt >= week.start }
            .map { calendar.startOfDay(for: $0.occurredAt) }).count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                Text("Fable")
                    .font(.custom("Georgia", size: 58, relativeTo: .largeTitle))
                    .tracking(-2.5)
                    .foregroundStyle(FablePalette.ink)
                    .padding(.top, 28)
                    .accessibilityAddTraits(.isHeader)

                NavigationLink {
                    StoryReaderView(story: story, progress: progress)
                } label: {
                    todayCard
                }
                .buttonStyle(.plain)

                journeyCard
            }
            .frame(maxWidth: 680, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
            .frame(maxWidth: .infinity)
        }
        .background(FablePalette.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var todayCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            StoryCoverView(story: story)
                .frame(height: 226)
                .frame(maxWidth: .infinity)
                .clipped()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("今日故事")
                        .foregroundStyle(FablePalette.accent)
                    Spacer()
                    Text(progress.isComplete ? "已读" : progress.hasStarted ? "阅读中" : "约 \(story.readingMinutes) 分钟")
                        .foregroundStyle(FablePalette.muted)
                }
                .font(.caption.weight(.semibold))

                Text(story.title)
                    .font(.system(.title, design: .serif, weight: .semibold))
                    .foregroundStyle(FablePalette.ink)

                Text(story.teaser)
                    .font(.body)
                    .foregroundStyle(FablePalette.muted)
                    .lineLimit(2)

                HStack {
                    Text(progress.isComplete ? "回顾故事" : progress.hasStarted ? "接着读" : "开始阅读")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(FablePalette.ink)
                .padding(.top, 9)
                .padding(.bottom, 2)
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FablePalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(FablePalette.line.opacity(0.45), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var journeyCard: some View {
        HStack(alignment: .center, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("你的知识旅程")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FablePalette.ink)
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(completedCount)")
                        .font(.system(.largeTitle, design: .serif, weight: .semibold))
                    Text("个已读概念")
                        .font(.subheadline)
                }
                .foregroundStyle(FablePalette.ink)
            }
            Spacer(minLength: 10)
            VStack(alignment: .trailing, spacing: 5) {
                Text("\(activeDaysThisWeek)")
                    .font(.system(.title, design: .serif, weight: .semibold))
                Text("本周活跃天数")
                    .font(.caption)
            }
            .foregroundStyle(FablePalette.muted)
        }
        .padding(22)
        .background(FablePalette.card, in: RoundedRectangle(cornerRadius: 22))
    }
}
