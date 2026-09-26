import SwiftUI

struct StoryReaderView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var learningStore: LearningStore
    @ScaledMetric(relativeTo: .title3) private var baseBodySize: CGFloat = 21
    @ScaledMetric(relativeTo: .body) private var baseInsightSize: CGFloat = 17
    @State private var phase: ReadingPhase
    @State private var sceneIndex: Int
    @State private var selectedChoice: String?
    @State private var pendingScrollScene: Int?

    let story: FableStory
    let wasCompleted: Bool

    init(story: FableStory, progress: StoryProgress, openAtInsight: Bool = false) {
        self.story = story
        wasCompleted = progress.isComplete
        _phase = State(initialValue: openAtInsight ? .insight : progress.phase)
        _sceneIndex = State(initialValue: min(max(progress.sceneIndex, 0), story.scenes.count - 1))
        _pendingScrollScene = State(initialValue: progress.sceneIndex)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    progressHeader
                    currentContent
                }
                .frame(maxWidth: 640, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .padding(.bottom, 48)
                .frame(maxWidth: .infinity)
            }
            .id(phase.rawValue)
            .onAppear {
                guard phase == .story, let target = pendingScrollScene else { return }
                pendingScrollScene = nil
                if target > 0 {
                    DispatchQueue.main.async {
                        proxy.scrollTo(target, anchor: .top)
                    }
                }
            }
        }
        .background(FablePalette.paper.ignoresSafeArea())
        .navigationTitle("寓言")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            learningStore.beginReading(story.id)
        }
    }

    private var progressHeader: some View {
        HStack {
            Text(story.category)
                .foregroundStyle(FablePalette.accent)
            Spacer()
            Text(stepLabel)
                .foregroundStyle(FablePalette.muted)
        }
        .font(.caption.weight(.semibold))
    }

    private var stepLabel: String {
        switch phase {
        case .story: wasCompleted ? "已读 · 回顾中" : "故事 \(sceneIndex + 1) / \(story.scenes.count)"
        case .guess: "猜想"
        case .reveal: "揭题"
        case .insight: "理解"
        }
    }

    @ViewBuilder
    private var currentContent: some View {
        switch phase {
        case .story: storyContent
        case .guess: guessContent
        case .reveal: revealContent
        case .insight: insightContent
        }
    }

    private var storyContent: some View {
        VStack(alignment: .leading, spacing: 38) {
            Text(story.title)
                .font(.system(.title, design: .serif, weight: .semibold))
                .foregroundStyle(FablePalette.ink)

            ForEach(story.scenes.indices, id: \.self) { index in
                let scene = story.scenes[index]
                VStack(alignment: .leading, spacing: 22) {
                    Text(String(format: "%02d  %@", scene.number, scene.title))
                        .font(.caption.weight(.semibold))
                        .tracking(2)
                        .foregroundStyle(FablePalette.accent)

                    Text(scene.text)
                        .font(.system(size: baseBodySize * learningStore.preferences.readerTextSize.scale, design: .serif))
                        .lineSpacing(8 * learningStore.preferences.readerTextSize.scale)
                        .foregroundStyle(FablePalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .id(index)
                .onScrollVisibilityChange(threshold: 0.15) { visible in
                    if visible && phase == .story && sceneIndex != index {
                        sceneIndex = index
                        learningStore.updateReading(story.id, phase: .story, sceneIndex: index)
                    }
                }
            }

            nextStep("读完了，猜猜看") { move(to: .guess) }
                .padding(.top, 6)
        }
    }

    private var guessContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 34))
                .foregroundStyle(FablePalette.accent)
            Text("这个故事在说什么？")
                .font(.system(.title, design: .serif, weight: .semibold))
                .foregroundStyle(FablePalette.ink)
            Text("先给自己一个答案。这里没有考试，也可以直接揭题。")
                .font(.body)
                .foregroundStyle(FablePalette.muted)
                .padding(.bottom, 10)

            ForEach(story.choices) { choice in
                Button {
                    selectedChoice = choice.title
                } label: {
                    HStack {
                        Text(choice.title)
                            .font(.headline)
                        Spacer()
                        Image(systemName: selectedChoice == choice.title ? "checkmark.circle.fill" : "circle")
                    }
                    .foregroundStyle(FablePalette.ink)
                    .padding(20)
                    .background(
                        selectedChoice == choice.title ? FablePalette.ink.opacity(0.10) : FablePalette.card,
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                }
                .buttonStyle(.plain)
            }

            nextStep("揭晓概念") { move(to: .reveal) }
                .padding(.top, 12)
            quietAction("回看故事") { move(to: .story, scene: 0) }
        }
    }

    private var revealContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("故事背后的概念")
                .font(.caption.weight(.semibold))
                .tracking(2)
                .foregroundStyle(FablePalette.accent)

            Text(story.concept)
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
                .foregroundStyle(FablePalette.ink)
            Text(story.conceptChinese)
                .font(.title2.weight(.medium))
                .foregroundStyle(FablePalette.ink)

            Rectangle()
                .fill(FablePalette.accent.opacity(0.35))
                .frame(height: 1)
                .padding(.vertical, 8)

            Text(story.insight)
                .font(.system(.title2, design: .serif))
                .foregroundStyle(FablePalette.ink)
                .fixedSize(horizontal: false, vertical: true)

            if let selectedChoice,
               let choice = story.choices.first(where: { $0.title == selectedChoice }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedChoice == story.conceptChinese ? "你猜对了。" : "你猜的是“\(selectedChoice)”。")
                        .font(.subheadline.weight(.semibold))
                    Text(choice.explanation)
                        .font(.subheadline)
                    if selectedChoice != story.conceptChinese,
                       let answer = story.choices.first(where: { $0.title == story.conceptChinese }) {
                        Text(answer.explanation)
                            .font(.subheadline)
                    }
                }
                .foregroundStyle(FablePalette.muted)
            }

            saveButton
                .padding(.top, 12)

            nextStep("继续理解") { move(to: .insight) }
                .padding(.top, 12)
            quietAction("稍后继续") { dismiss() }
        }
    }

    private var insightContent: some View {
        VStack(alignment: .leading, spacing: 26) {
            VStack(alignment: .leading, spacing: 8) {
                Text(story.conceptChinese)
                    .font(.system(.title, design: .serif, weight: .semibold))
                    .foregroundStyle(FablePalette.ink)
                Text(story.insight)
                    .font(.title3)
                    .foregroundStyle(FablePalette.muted)
            }

            insightSection(title: "为什么", text: story.explanation)
            insightSection(title: "现实中的样子", text: story.businessExample)
            insightSection(title: "别和它混淆", text: story.comparison)

            VStack(alignment: .leading, spacing: 14) {
                Text("顺便学三个词")
                    .font(.headline)
                    .foregroundStyle(FablePalette.ink)
                ForEach(story.words) { word in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(word.term)
                            .font(.headline)
                            .foregroundStyle(FablePalette.ink)
                        Text("\(word.origin) · \(word.meaning)")
                            .font(.subheadline)
                            .foregroundStyle(FablePalette.muted)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
            .background(FablePalette.card, in: RoundedRectangle(cornerRadius: 20))

            saveButton
            nextStep("完成阅读") {
                learningStore.finishReading(story.id)
                dismiss()
            }
        }
    }

    private func insightSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(FablePalette.accent)
            Text(text)
                .font(.system(size: baseInsightSize * learningStore.preferences.readerTextSize.scale))
                .lineSpacing(5)
                .foregroundStyle(FablePalette.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(FablePalette.card, in: RoundedRectangle(cornerRadius: 20))
    }

    private var saveButton: some View {
        Button {
            learningStore.toggleSaved(story.id)
        } label: {
            Label(learningStore.progress(for: story.id).isSaved ? "已收藏这句话" : "收藏这句话",
                  systemImage: learningStore.progress(for: story.id).isSaved ? "bookmark.fill" : "bookmark")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(FablePalette.accent)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(learningStore.progress(for: story.id).isSaved ? "取消收藏" : "收藏认知句")
    }

    private func move(to phase: ReadingPhase, scene: Int? = nil) {
        self.phase = phase
        if let scene {
            sceneIndex = scene
            pendingScrollScene = scene
        }
        learningStore.updateReading(story.id, phase: phase, sceneIndex: sceneIndex)
    }

    private func nextStep(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "arrow.right")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(FablePalette.ink)
            .padding(.vertical, 14)
            .overlay(alignment: .bottom) {
                FablePalette.ink.opacity(0.18).frame(height: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func quietAction(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.subheadline)
            .foregroundStyle(FablePalette.muted)
            .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        StoryReaderView(story: StoryCatalog.stories[0], progress: StoryProgress())
    }
    .environmentObject(LearningStore())
}
