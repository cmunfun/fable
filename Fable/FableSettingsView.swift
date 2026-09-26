import SwiftUI

struct FableSettingsView: View {
    @EnvironmentObject private var learningStore: LearningStore

    private var cloudBinding: Binding<Bool> {
        Binding(
            get: { learningStore.isCloudSyncEnabled },
            set: { learningStore.setCloudSyncEnabled($0) }
        )
    }
    private var textSizeBinding: Binding<ReaderTextSize> {
        Binding(
            get: { learningStore.preferences.readerTextSize },
            set: { learningStore.setReaderTextSize($0) }
        )
    }

    var body: some View {
        Form {
            Section {
                Toggle(isOn: cloudBinding) {
                    Label("iCloud 同步", systemImage: "icloud")
                }
                HStack(spacing: 10) {
                    Image(systemName: statusIcon)
                        .foregroundStyle(statusColor)
                    Text(statusText)
                        .font(.subheadline)
                        .foregroundStyle(FablePalette.muted)
                }
                if learningStore.isCloudSyncEnabled && learningStore.cloudStatus == .unavailable {
                    Button("重新连接") {
                        learningStore.retryCloudSync()
                    }
                }
            } footer: {
                Text("开启后同步阅读位置、已学概念、收藏、复习记录、活跃度和阅读偏好。同步需要同一 Apple 账户与 iCloud 权限。")
            }

            Section("阅读") {
                Picker("正文字号", selection: textSizeBinding) {
                    ForEach(ReaderTextSize.allCases) { size in
                        Text(size.title).tag(size)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .scrollContentBackground(.hidden)
        .background(FablePalette.paper.ignoresSafeArea())
        .navigationTitle("设置")
        .toolbar(.visible, for: .navigationBar)
    }

    private var statusIcon: String {
        switch learningStore.cloudStatus {
        case .off: "iphone"
        case .active: "checkmark.icloud"
        case .unavailable: "exclamationmark.icloud"
        }
    }

    private var statusColor: Color {
        learningStore.cloudStatus == .active ? FablePalette.ink : FablePalette.accent
    }

    private var statusText: String {
        switch learningStore.cloudStatus {
        case .off: "当前仅保存在这台设备"
        case .active: "iCloud 同步已开启"
        case .unavailable: "iCloud 暂不可用，请检查账户与应用权限"
        }
    }
}
