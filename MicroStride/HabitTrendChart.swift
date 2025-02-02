//
//  HabitTrendChart.swift
//  MicroStride
//  这个页面是负责折线图的绘制，然后也许可以在这里设置一下绘图算法
//  Created by 郭博文 on 2025/1/31.
//

import SwiftUI
import Charts

// ✅ 定义折线图的数据点
struct HabitDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let completed: Bool
}

// ✅ 习惯趋势折线图
struct HabitTrendChart: View {
    var habit: Habit
    
    var body: some View {
        Chart(habitData()) { data in
            LineMark(
                x: .value("日期", data.date),
                y: .value("完成情况", data.completed ? 1 : 0)
            )
            .lineStyle(StrokeStyle(lineWidth: 2))
            .foregroundStyle(.blue)
        }
        .chartXAxis {
            AxisMarks(values: habitData().map { $0.date }) { date in
                AxisValueLabel {
                    if let date = date.as(Date.self) {
                        Text(dateFormatter.string(from: date))
                            .font(.caption)
                    }
                }
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks(values: [0, 1]) { value in
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text(intValue == 1 ? "完成" : "未完成")
                            .font(.caption)
                    }
                }
                AxisGridLine()
            }
        }
    }
    
    // ✅ 生成完整的趋势数据
    private func habitData() -> [HabitDataPoint] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let today = calendar.startOfDay(for: Date()) // 只取日期部分
        let startDate = calendar.date(byAdding: .day, value: -7, to: today)! // 7 天前
        let endDate = calendar.date(byAdding: .day, value: 7, to: today)! // 7 天后

        var dataPoints: [HabitDataPoint] = []
        var currentDate = startDate

        while currentDate <= endDate {
            let key = dateFormatter.string(from: currentDate)
            let completed = habit.completionHistory[key] ?? false
            dataPoints.append(HabitDataPoint(date: currentDate, completed: completed))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)! // 加一天
        }
            
        return dataPoints
    }

    // 日期格式化
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }
}

// ✅ 预览
#Preview {
    HabitTrendChart(habit: Habit(name: "唱歌", endDate: Calendar.current.date(byAdding: .day, value: 20, to: Date())!,
        completionHistory: [
            "2025-02-02": true,
            "2025-02-04": true,
            "2025-02-06": true,
            "2025-02-08": true,
            "2025-02-10": true
        ]
    ))
}
