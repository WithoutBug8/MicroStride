//
//  Habit.swift
//  MicroStride
//  这是一个Habit结构体，定义Habit数据结构，用于存储习惯信息
//  Created by 郭博文 on 2025/1/31.
//

import Foundation

struct Habit: Identifiable, Codable {
    var id: UUID
    var name: String
    var completionHistory: [String: Bool]  // ✅ 用字符串作为 Key
    var endDate: Date  // ✅ 新增截止日期属性

    init(id: UUID = UUID(), name: String, endDate: Date, completionHistory: [String: Bool] = [:]) {
        self.id = id
        self.name = name
        self.endDate = endDate
        self.completionHistory = completionHistory
    }
}

// 获取当前日期的 Key（yyyy-MM-dd）
func todayKey() -> String {
    return dateKey(from: Date())
}

// 获取特定日期的 Key（yyyy-MM-dd）
func dateKey(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

