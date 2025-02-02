//
//  Formula.swift
//  MicroStride
//  这页的内容主要负责实现公式算法的计算
//  Created by 郭博文 on 2025/2/2.
//

import SwiftUI

func computeHabitValue(
    habit: Habit,
    beta: Double = 0.2,
    gamma: Double = 0.1,
    V0: Double = 0.1
) -> Double {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let endDay = calendar.startOfDay(for: habit.endDate)
    
    guard let numDays = calendar.dateComponents([.day], from: today, to: endDay).day else {
        return V0
    }
    if numDays <= 0 { return V0 }

    var V = V0
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    // ✅【调试输出】开始计算（只打印一次）
    print("[DEBUG] computeHabitValue START - habit: \(habit.name), V0=\(V0), numDays=\(numDays)")

    for offset in 0..<numDays {
        guard let theDate = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
        let dayKey = dateFormatter.string(from: theDate)
        let X_t = habit.completionHistory[dayKey] == true ? 1.0 : 0.0
        
        // 应用公式
        V = V + beta * X_t * (1 - V) - gamma * (1 - X_t) * V
        
        // 强制 V 在 [0,1]
        V = min(max(V, 0), 1)
        
        // ✅【调试输出】(已注释，减少日志):
        // print("[DEBUG] day offset=\(offset), date=\(dayKey), X_t=\(X_t), V_before=\(oldV), V_after=\(V)")
    }
    
    // ✅【调试输出】只打印最终结果
    print("[DEBUG] computeHabitValue END - habit: \(habit.name), Final V=\(V)\n")
    
    return V
}

// MARK: - 测试 / 示例视图
/// 仅作示范：展示 computeHabitValue 的计算结果（可在预览或测试界面查看）
struct HabitValueView: View {
    let habit: Habit

    var body: some View {
        // 调用公式，得到 [0,1] 区间的最终强度
        let finalV = computeHabitValue(habit: habit, beta: 0.2, gamma: 0.1, V0: 0.1)
        
        // UI 上显示：把 finalV 转成百分比
        Text("最终习惯值：\(finalV * 100, specifier: "%.2f")%")
            .padding()
    }
}

// MARK: - 预览示例
struct HabitValueView_Previews: PreviewProvider {
    static var previews: some View {
        // 造一个测试 Habit：假设有几天的打卡记录
        let sampleHistory: [String: Bool] = [
            "2025-02-01": true,
            "2025-02-02": false,
            "2025-02-03": true,
            "2025-02-04": true
        ]
        
        // 假设截止日期在 10 天后
        let futureDate = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()
        
        let habit = Habit(name: "阅读",
                          endDate: futureDate,
                          completionHistory: sampleHistory)

        return HabitValueView(habit: habit)
    }
}
