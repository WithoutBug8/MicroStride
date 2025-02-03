//
//  ContentView.swift
//  MicroStride
//
//  Created by 郭博文 on 2025/1/31.
//

import SwiftUI

struct ContentView: View {
    
    @State private var habits: [Habit] = [] {
        didSet { saveHabits() }
    }
    @State private var selectedHabit: Habit? // 追踪选中的习惯
    @State private var showAddHabitView = false // 控制新建页面的显示
    @State private var showEditHabitView = false // 控制编辑页面的显示

    var body: some View {
            ZStack {
                // ✅ 添加渐变背景
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.black.opacity(0.9)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all) // 让背景覆盖整个屏幕
                
                NavigationSplitView {
                    VStack {
                        greetingView()
                        progressView()
                        statsView()
                        habitListView()
                    }
                    .frame(width: 350)
                    .background(
                        BlurView() // ✅ 使用毛玻璃背景，让列表部分有透明感
                    )
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: { showAddHabitView = true }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $showAddHabitView) {
                        AddHabitView(habits: $habits)
                    }
                } detail: {
                    if let habit = selectedHabit, let index = habits.firstIndex(where: { $0.id == habit.id }) {
                        HabitDetailView(habit: $habits[index], habits: $habits, onUpdate: saveHabits)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ZStack {
                            BlurView() // ✅ 添加毛玻璃背景，即使未选中习惯
                                .ignoresSafeArea()
                            
                            Text("选择一个习惯查看详情")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .sheet(isPresented: $showEditHabitView) {
                    if let habit = selectedHabit,
                       let index = habits.firstIndex(where: { $0.id == habit.id }) {
                        EditHabitView(habit: $habits[index], habits: $habits)
                    } else {
                        Text("未选中任何习惯")
                            .padding()
                    }
                }
            }
            .onAppear {
                if !isPreviewMode {
                    loadHabits()
                }
            }
        }
    
    // MARK: - 顶部问候
    private func greetingView() -> some View {
        Text("Hi, 你今天的习惯进展如何？")
            .font(.title2)
            .padding(.top, 20)
    }

    // MARK: - 进度条
    private func progressView() -> some View {
        ProgressView(value: calculateOverallProgress())
            .progressViewStyle(LinearProgressViewStyle())
            .frame(width: 300)
            .padding()
    }

    // MARK: - 统计数据
    private func statsView() -> some View {
        HStack(spacing: 20) {
            StatCard(title: "总习惯", value: "\(habits.count)")
            StatCard(title: "已完成", value: "\(calculateCompletedHabits())")
            StatCard(title: "连续天数", value: "\(calculateStreak())")
        }
        .padding()
    }
    
    // MARK: - 习惯列表
    private func habitListView() -> some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(habits.indices, id: \.self) { index in
                    habitCard(for: index)
                }
            }
            .padding()
        }
    }
    
    // MARK: - 构建单个 HabitCardView
    private func habitCard(for index: Int) -> some View {
        let habit = habits[index]
        
        // ✅【调试输出】构建卡片前
        print("[DEBUG] Building card for \(habit.name), endDate=\(habit.endDate)")

        let ratio = computeHabitValue(habit: habit) // 会触发 Formula.swift 的调试输出
        let percentage = ratio * 100
        
        // ✅【调试输出】查看算出的百分比
        print("[DEBUG] \(habit.name) -> computed ratio=\(ratio), which is \(percentage)%")

        // 然后根据百分比决定描述和颜色
        let trendDescription: String
        let trendColor: Color
        switch percentage {
        case let p where p > 80:
            trendDescription = "习惯已相当稳固"
            trendColor = .green
        case let p where p > 40:
            trendDescription = "显著提高"
            trendColor = .green
        case let p where p > 10:
            trendDescription = "保持稳定"
            trendColor = .orange
        default:
            trendDescription = "仍需努力"
            trendColor = .red
        }
        
        return HabitCardView(
            habit: habit,
            trendPercentage: percentage,
            trendDescription: trendDescription,
            trendColor: trendColor
        ) {
            selectedHabit = habit
        }
        .contextMenu {
            Button("编辑") {
                selectedHabit = habit
                showEditHabitView = true
            }
            Button("删除", role: .destructive) {
                deleteHabit(at: IndexSet(integer: index))
            }
        }
    }

    //==========================
    //  下方原有的辅助函数不变
    //==========================

    // ✅ 计算习惯总进度
    private func calculateOverallProgress() -> Double {
        return habits.isEmpty ? 0 : Double(calculateCompletedHabits()) / Double(habits.count)
    }

    private func calculateCompletedHabits() -> Int {
        let today = todayKey()
        return habits.filter { $0.completionHistory[today] == true }.count
    }

    // ✅ 计算连续天数（示例逻辑）
    private func calculateStreak() -> Int {
        let today = todayKey()
        var streak = 0
        var date = today
        
        guard !habits.isEmpty else { return 0 }

        while habits.allSatisfy({ $0.completionHistory[date] == true }) {
            streak += 1
            if let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: parseDate(from: date)) {
                date = todayKey(from: previousDate)
            } else {
                break
            }
        }
        return streak
    }

    // ✅ 删除习惯
    private func deleteHabit(at offsets: IndexSet) {
        let habitToDelete = habits[offsets.first!]
        habits.remove(atOffsets: offsets)

        if selectedHabit?.id == habitToDelete.id {
            selectedHabit = nil
        }
    }

    // ✅ 数据存储
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            // 为了和后续的插件进行数据通讯这里要修改一下
            let sharedDefaults = UserDefaults(suiteName: "group.com.example.MicroStride")
            sharedDefaults?.set(encoded, forKey: "habits")
            sharedDefaults?.synchronize()
            print("[DEBUG] 主应用 - 数据已存入 App Group: \(encoded.count) bytes") // 调试信息
        }
    }
    // 加载数据；这里也做了处理，从 App Group 读取数据；用于后续widget插件读取数据
    private func loadHabits() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.example.MicroStride")
        if let savedData = sharedDefaults?.data(forKey: "habits"),
           let decoded = try? JSONDecoder().decode([Habit].self, from: savedData) {
            habits = decoded
            print("[DEBUG] 主应用 - 成功加载习惯数据，共 \(decoded.count) 个习惯") // ✅ 调试信息
        } else{
            print("[DEBUG] 主应用 - 习惯数据加载失败或数据为空") // ✅ 调试信息
        }
    }

    // ✅ 日期转换
    private func parseDate(from dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }

    private func todayKey(from date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private var isPreviewMode: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

// 统计卡片组件（保持不变）
struct StatCard: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 80, height: 80)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}
