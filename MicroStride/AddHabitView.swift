//
//  AddHabitView.swift
//  MicroStride
//  这个页面适用于添加新的习惯用的
//  Created by 郭博文 on 2025/1/31.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var habits: [Habit]

    @State private var habitName: String = ""
    @State private var selectedDate: Date = Date()

    var body: some View {
        VStack(spacing: 16) { // ✅ 让间距更紧凑
            // 标题
            Text("新建习惯")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 10)

            // 输入框
            VStack(alignment: .leading, spacing: 6) {
                Text("习惯名称")
                    .font(.headline)
                TextField("输入习惯名称", text: $habitName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            // 日期选择
            VStack(alignment: .leading, spacing: 6) {
                Text("截止日期")
                    .font(.headline)
                DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }

            // 按钮组（水平排列）
            HStack {
                // 取消按钮
                Button("取消") {
                    dismiss()
                }
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)

                Spacer()
                
                // 添加按钮（去掉系统样式，改用自定义背景等）
                Button {
                    addHabit()
                } label: {
                    Text("添加")
                        .foregroundColor(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(habitName.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(habitName.isEmpty ? Color.clear : Color.blue, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)        // ✅ 去掉系统默认按钮样式
                .disabled(habitName.isEmpty)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 300) // ✅ 保持标准窗口大小
        .background(Color(NSColor.windowBackgroundColor)) // ✅ 让面板和窗口颜色融合
        .cornerRadius(8) // ✅ 让窗口边角更协调
        .shadow(radius: 4) // ✅ 适度的视觉层次感
        .padding()
    }

    // 添加习惯
    private func addHabit() {
        let newHabit = Habit(name: habitName, endDate: selectedDate) // ✅ 记录截止日期
        habits.append(newHabit)
        dismiss()
    }
}

// ✅ 预览
#Preview {
    AddHabitView(habits: .constant([]))
}
