//
//  HabitDetailView.swift
//  MicroStride
//  这个页面是从主界面点击添加好的习惯之后，跳转到这个界面
//  Created by 郭博文 on 2025/1/31.
//

import SwiftUI
import Charts

// 环形进度条
struct CircularProgressView: View {
    var progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 10) // 背景圆圈
            Circle()
                .trim(from: 0, to: CGFloat(progress)) // 进度部分
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90)) // 旋转到起始位置

            Text(String(format: "%.0f%%", progress * 100)) // 显示百分比
                .font(.headline)
                .bold()
        }
    }
}

struct HabitDetailView: View {
    @Binding var habit: Habit
    @Binding var habits: [Habit] // 绑定整个习惯列表
    var onUpdate: () -> Void // 触发主视图更新
    
    var body: some View {
        ZStack {
            BlurView() // ✅ 添加毛玻璃背景
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // 标题
                    VStack {
                        Text(habit.name)
                            .font(.largeTitle)
                            .bold()
                        Text("截止日期: " + dateKey(from: habit.endDate))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    // 进度环
                    CircularProgressView(progress: calculateProgress())
                        .frame(width: 150, height: 150)

                    // 统计数据
                    HStack(spacing: 20) {
                        StatCard(title: "已完成天数", value: "\(completedDays()) 天")
                        StatCard(title: "习惯进度", value: String(format: "%.0f%%", calculateProgress() * 100))
                    }

                    Button(action: markHabitCompleted) {
                        Text("立即打卡")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(PlainButtonStyle()) // 去掉 macOS 默认按钮样式

                    // 折线趋势图
                    VStack(alignment: .leading) {
                        Text("趋势")
                            .font(.headline)
                            .padding(.leading)
                        HabitTrendChart(habit: habit)
                            .frame(height: 150)
                            .padding()
                    }

                    // 评估信息
                    evaluationView()
                        .padding()
                }
                .padding()
            }
        }
    }
    
    // MARK: - 打卡
    private func markHabitCompleted() {
        let today = todayKey()
        print("[DEBUG] markHabitCompleted tapped. todayKey = \(today)")
        
        // 打印一下打卡前的状态
        print("[DEBUG] Before update, habit.completionHistory[\(today)] = \(String(describing: habit.completionHistory[today]))")
        
        // 设置当天打卡
        habit.completionHistory[today] = true
        
        // 打印一下打卡后的状态
        print("[DEBUG] After update, habit.completionHistory[\(today)] = \(String(describing: habit.completionHistory[today]))")

        // 在习惯数组中找到同一个 Habit，并更新
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            print("[DEBUG] Found habit at index=\(index), updating habits[index]")
            habits[index] = habit
        } else {
            print("[DEBUG] Could NOT find habit in the list. No update performed.")
        }
        
        // 触发上层视图更新
        onUpdate()
        print("[DEBUG] onUpdate() called.\n")
    }

    // MARK: - 计算进度
    private func calculateProgress() -> Double {
        let totalDays = Calendar.current.dateComponents([.day], from: Date(), to: habit.endDate).day ?? 7
        let daysCompleted = completedDays()
        let rawProgress = Double(daysCompleted) / Double(totalDays)
        
        print("[DEBUG] calculateProgress() - totalDays=\(totalDays), daysCompleted=\(daysCompleted), rawProgress=\(rawProgress)")
        
        return min(rawProgress, 1.0)
    }
    
    // MARK: - 计算完成天数
    private func completedDays() -> Int {
        let count = habit.completionHistory.count
        print("[DEBUG] completedDays() - completionHistory=\(habit.completionHistory), count=\(count)")
        return count
    }
    
    // MARK: - 评估信息视图
    private func evaluationView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("评估")
                .font(.headline)
            Text(evaluateHabit())
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
        }
    }
    
    private func evaluateHabit() -> String {
        let progress = calculateProgress()
        if progress >= 0.8 {
            return "你的习惯保持得很好，继续保持！"
        } else if progress >= 0.5 {
            return "你的习惯正在养成，加油！"
        } else {
            return "你的习惯进展较慢，尝试更频繁地完成它！"
        }
    }
}

// MARK: - 预览
#Preview {
    HabitDetailView(
        habit: .constant(Habit(name: "阅读", endDate: Date().addingTimeInterval(86400*7))), // 加7天
        habits: .constant([Habit(name: "阅读", endDate: Date().addingTimeInterval(86400*7))]),
        onUpdate: {}
    )
}
