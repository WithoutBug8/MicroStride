//
//  HabitCardView.swift
//  MicroStride
//  这个页面负责的功能是习惯卡片，
//  Created by 郭博文 on 2025/1/31.
//

import SwiftUI

struct HabitCardView: View {
    var habit: Habit
    var trendPercentage: Double // 变化趋势
    var trendDescription: String // 变化描述（"显著提高"、"下降"等）
    var trendColor: Color // 颜色，根据趋势选择
    var onTap: () -> Void  // 点击事件

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(trendDescription)
                    .font(.headline)
                    .foregroundColor(trendColor)
                Spacer()
                Text(String(format: "%.0f%%", trendPercentage))
                    .font(.headline)
                    .foregroundColor(trendColor)
            }

            HStack {
                Text(habit.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // ✅ 显示截止日期
            Text("截止日期: " + dateKey(from: habit.endDate))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16)
            .fill(Color(NSColor.windowBackgroundColor))
            .shadow(radius: 3))
        .onTapGesture {
            onTap()
        }
        .padding(.horizontal)
    }
}

// 预览
#Preview {
    HabitCardView(
        habit: Habit(name: "阅读", endDate: Date()), // ✅ 添加截止日期
        trendPercentage: -2,
        trendDescription: "保持稳定",
        trendColor: .red,
        onTap: {}
    )
}

