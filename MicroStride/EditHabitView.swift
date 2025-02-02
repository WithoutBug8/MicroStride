//
//  EditHabitView.swift
//  MicroStride
//  这个页面用于修改已有的习惯，很像AddHabitView这个页面
//  Created by 郭博文 on 2025/2/2.
//

import SwiftUI

struct EditHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var habit: Habit // ✅ 绑定现有习惯
    @Binding var habits: [Habit] // ✅ 绑定习惯列表

    @State private var habitName: String
    @State private var selectedDate: Date

    init(habit: Binding<Habit>, habits: Binding<[Habit]>) {
        self._habit = habit
        self._habits = habits
        self._habitName = State(initialValue: habit.wrappedValue.name)
        self._selectedDate = State(initialValue: habit.wrappedValue.endDate)
    }

    var body: some View {
        VStack(spacing: 16) {
            // 标题
            Text("编辑习惯")
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

            // 截止日期选择
            VStack(alignment: .leading, spacing: 6) {
                Text("截止日期")
                    .font(.headline)
                DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }

            // 按钮组
            HStack {
                Button("取消") {
                    dismiss()
                }
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)

                Spacer()

                Button {
                    updateHabit()
                } label: {
                    Text("保存")
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
                .buttonStyle(.plain)      // 去掉默认按钮样式
                .disabled(habitName.isEmpty)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 300)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 4)
        .padding()
    }

    // ✅ 更新习惯数据
    private func updateHabit() {
        habit.name = habitName
        habit.endDate = selectedDate

        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
        }

        dismiss() // 关闭编辑窗口
    }
}

// ✅ 预览
#Preview {
    EditHabitView(
        habit: .constant(Habit(name: "阅读", endDate: Date())),
        habits: .constant([Habit(name: "阅读", endDate: Date())])
    )
}
