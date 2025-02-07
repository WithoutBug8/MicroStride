//
//  MicroStrideWidget.swift
//  MicroStrideWidget
//
//  Created by 郭博文 on 2025/2/3.
//

import WidgetKit
import SwiftUI

// ✅ 使用 App Group 读取数据
let appGroupIdentifier = "group.com.example.MicroStride"

// ✅ 数据提供者
struct Provider: TimelineProvider {
    // ✅ `placeholder` 需要直接返回一个 `HabitEntry`
    func placeholder(in context: Context) -> HabitEntry {
        return HabitEntry(date: Date(), completedCount: 2, totalCount: 5)
    }

    // ✅ `snapshot` 需要传递 `completion` 但不能省略参数
    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> Void) {
        let entry = HabitEntry(date: Date(), completedCount: fetchCompletedHabits(), totalCount: fetchTotalHabits())
        completion(entry)
    }

    // ✅ `timeline` 生成时间线
    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitEntry>) -> Void) {
        let currentDate = Date()
        let entry = HabitEntry(date: currentDate, completedCount: fetchCompletedHabits(), totalCount: fetchTotalHabits())

        // ✅ 每 30 分钟更新
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    // ✅ 从 App Group UserDefaults 获取今天完成的习惯数
    private func fetchCompletedHabits() -> Int {
        let today = todayKey()
        let sharedDefaults = UserDefaults(suiteName: "group.com.example.MicroStride")

        if let savedData = sharedDefaults?.data(forKey: "habits"),
           let decoded = try? JSONDecoder().decode([Habit].self, from: savedData) {
            print("[DEBUG] Widget 读取到习惯数: \(decoded.count)")
            return decoded.filter { $0.completionHistory[today] == true }.count
        }

        print("[ERROR] Widget 无法读取 App Group 里的习惯数据")
        return 0
    }
    // ✅ 从 App Group UserDefaults 获取总习惯数
    private func fetchTotalHabits() -> Int {
        let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)

        guard let savedData = sharedDefaults?.data(forKey: "habits"),
              let decoded = try? JSONDecoder().decode([Habit].self, from: savedData) else {
            return 0
        }

        return decoded.count
    }
}

// ✅ 习惯进度数据结构
struct HabitEntry: TimelineEntry {
    let date: Date
    let completedCount: Int
    let totalCount: Int
}

// ✅ 小组件 UI，这里主要负责美化
struct MicroStrideWidgetEntryView: View {
    var entry: HabitEntry

    var body: some View {
        ZStack {
            LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            VStack(spacing: 8) {
                // ✅ 状态鼓励语
                Text(motivationalText(for: entry.completedCount, total: entry.totalCount))
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)

                // ✅ 习惯进度
                Text("\(entry.completedCount) / \(entry.totalCount)")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                // ✅ 进度条
                ProgressView(value: entry.totalCount > 0 ? Double(entry.completedCount) / Double(entry.totalCount) : 0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 100)
                    .padding(.horizontal, 10)
                
                // ✅ 可爱的 emoji
                Text(emojiForProgress(entry.completedCount, total: entry.totalCount))
                    .font(.system(size: 40)) // 让 emoji 更大
            }
        }
        .ignoresSafeArea() // 确保背景完全覆盖
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 让 VStack 也填充 Widget
    }
    
    // ✅ 根据进度生成鼓励话语
    private func motivationalText(for completed: Int, total: Int) -> String {
        guard total > 0 else { return "开始新的一天吧！💪" }
        let progress = Double(completed) / Double(total)
        
        switch progress {
        case 0.8...:
            return "状态优秀！继续前进！🚀"
        case 0.5...:
            return "进度不错，坚持就是胜利！✨"
        case 0.1...:
            return "迈出一小步也是进步！💡"
        default:
            return "别灰心，今天可以加油哦！🔥"
        }
    }

    // ✅ 根据进度选择 emoji
    private func emojiForProgress(_ completed: Int, total: Int) -> String {
        guard total > 0 else { return "😊" }
        let progress = Double(completed) / Double(total)
        
        switch progress {
        case 0.8...:
            return "😎"
        case 0.5...:
            return "😌"
        case 0.1...:
            return "🙂"
        default:
            return "😅"
        }
    }
}

// ✅ 小组件定义
struct MicroStrideWidget: Widget {
    let kind: String = "MicroStrideWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MicroStrideWidgetEntryView(entry: entry)
                // .containerBackground(.fill.tertiary, for: .widget) 外层容器背景删除，影响widget展示
        }
        .configurationDisplayName("MicroStride 习惯追踪")
        .description("查看今日习惯完成进度")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// ✅ 日期转换
private func todayKey(from date: Date = Date()) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}
