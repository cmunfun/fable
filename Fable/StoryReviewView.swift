import SwiftUI

struct StoryReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var learningStore: LearningStore
    @State private var selectedChoice: String?
    @State private var didCheck = false

    let story: FableStory

    private var isCorrect: Bool { selectedChoice == story.conceptChinese }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("隔一段时间，再自己想起来。")
                    .font(.subheadline)
                    .foregroundStyle(FablePalette.muted)

                Text(story.recallPrompt)
                    .font(.system(.title2, design: .serif, weight: .semibold))
                    .foregroundStyle(FablePalette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 12) {
                    ForEach(story.choices) { choice in
                        Button {
                            selectedChoice = choice.title
                        } label: {
                            HStack {
                                Text(choice.title)
                                Spacer()
                                Image(systemName: selectedChoice == choice.title ? "checkmark.circle.fill" : "circle")
                            }
                            .font(.headline)
                            .foregroundStyle(FablePalette.ink)
                            .padding(20)
                            .background(
                                selectedChoice == choice.title ? FablePalette.ink.opacity(0.10) : FablePalette.card,
                                in: RoundedRectangle(cornerRadius: 18)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(didCheck)
                    }
                }

                if didCheck {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(isCorrect ? "想起来了" : "这次再记住它")
                            .font(.title3.weight(.semibold))
                        Text("答案：\(story.conceptChinese)")
                            .font(.headline)
                        if let selectedChoice,
                           let choice = story.choices.first(where: { $0.title == selectedChoice }) {
                            Text(choice.explanation)
                        }
                        if !isCorrect,
                           let answer = story.choices.first(where: { $0.title == story.conceptChinese }) {
                            Text(answer.explanation)
                        }
                        Text(isCorrect ? "下次复习会安排得更远一些。" : "明天会再提醒你复习这张卡片。")
                            .font(.subheadline)
                            .foregroundStyle(FablePalette.muted)
                    }
                    .foregroundStyle(FablePalette.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(22)
                    .background(FablePalette.card, in: RoundedRectangle(cornerRadius: 20))
                }
            }
            .frame(maxWidth: 640, alignment: .leading)
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .background(FablePalette.paper.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            Button {
                if didCheck {
                    dismiss()
                } else {
                    learningStore.recordReview(story.id, correct: isCorrect)
                    didCheck = true
                }
            } label: {
                Text(didCheck ? "完成复习" : "确认答案")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(FablePalette.card)
                    .padding(.vertical, 17)
                    .background(FablePalette.ink, in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!didCheck && selectedChoice == nil)
            .opacity(!didCheck && selectedChoice == nil ? 0.5 : 1)
            .frame(maxWidth: 640)
            .padding(.horizontal, 24)
            .padding(.top, 14)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity)
            .background(FablePalette.paper)
        }
        .navigationTitle("复习")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    NavigationStack {
        StoryReviewView(story: StoryCatalog.stories[0])
    }
    .environmentObject(LearningStore())
}
