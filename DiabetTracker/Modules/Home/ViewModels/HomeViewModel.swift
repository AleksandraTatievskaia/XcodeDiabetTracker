//
//  HomeViewModel.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 24.02.2026.
// Получение данных из БД, хранение и передача их в View

import Foundation
import RealmSwift
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var glucoseUnit: String = "ммоль/л"
    @Published var dailyGoal: Int = 1
    @Published var lastValue: Double = 0.0
    @Published var lastEntryDate: String = "--.--.---- --:--"
    @Published var statusMessage: String = "Нет данных для анализа"
    @Published var statusColor: Color = .black
    @Published var entries: [GlucoseEntry] = []
    @Published var todayCount: Int = 0
    
    private var realm: Realm?
    
    init() {
        realm = RealmService.shared.localRealm
        fetchData()
    }
    
    func fetchData() {
            guard let realm = realm else { return }
            
            // 1. Грузим профиль (чтобы получить единицы измерения)
            if let profile = realm.objects(UserProfile.self).first {
                self.userName = profile.name
                self.glucoseUnit = profile.glucoseUnit
                self.dailyGoal = profile.dailyGoal
            }
            
            let now = Date()
            let calendar = Calendar.current
            let past24Hours = calendar.date(byAdding: .hour, value: -24, to: now)!
            let startOfToday = calendar.startOfDay(for: now)

            // 2. Для графика берем замеры только за последние 24 часа
            let recentEntries = realm.objects(GlucoseEntry.self)
                .filter("date >= %@", past24Hours)
                .sorted(byKeyPath: "date", ascending: true)
            self.entries = Array(recentEntries)
            
            // 3. для анализа берем все замеры за сегодня
            let todayEntries = realm.objects(GlucoseEntry.self)
                .filter("date >= %@", startOfToday)
                .sorted(byKeyPath: "date", ascending: true)
            self.entries = Array(todayEntries)
            self.todayCount = todayEntries.count // Учет количества записей в БД

            if let last = todayEntries.last {
                self.lastValue = last.value
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy\nHH:mm"
                self.lastEntryDate = formatter.string(from: last.date)
                
                // Считаем статус на основе сегодняшних замеров
                calculateStatus(current: last.value, todayHistory: Array(todayEntries))
            }
        }
    
    private func calculateStatus(current: Double, todayHistory: [GlucoseEntry]) {
            // Если замер сегодня только один, сравнивать не с чем
            guard todayHistory.count > 1 else {
                statusMessage = "Первый замер за сегодня. Продолжайте наблюдение."
                statusColor = .black
                return
            }
            
            let values = todayHistory.map { $0.value }
            let average = values.reduce(0, +) / Double(values.count)
            
            let percentageDiff = (abs(current - average) / average) * 100
            
            if percentageDiff > 80 {
                statusMessage = "Замечено значительное отклонение от ваших показателей за сегодня. Обратите внимание на самочувствие."
                statusColor = .orange
            } else {
                statusMessage = "Отличная новость! Ваши показатели сегодня стабильны."
                statusColor = .black
            }
        }
}
