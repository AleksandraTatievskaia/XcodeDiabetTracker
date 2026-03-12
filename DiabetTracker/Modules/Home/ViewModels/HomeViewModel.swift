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
    @Published var todayCount: Int = 0 // счетчик замеров за сегодня
    
    private var realm: Realm?
    
    init() {
        realm = RealmService.shared.localRealm
        fetchData()
    }
    
    func fetchData() {
            guard let realm = RealmService.shared.localRealm else { return }
            realm.refresh() // Принудительно обновляем состояние БД

            if let profile = realm.objects(UserProfile.self).first {
                self.userName = profile.name
                self.glucoseUnit = profile.glucoseUnit
                self.dailyGoal = profile.dailyGoal
            }

            // Самый последний замер 
            let allEntries = realm.objects(GlucoseEntry.self).sorted(byKeyPath: "date", ascending: true)
            if let last = allEntries.last {
                self.lastValue = last.value
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy\nHH:mm"
                self.lastEntryDate = formatter.string(from: last.date)
                calculateStatus(current: last.value, history: Array(allEntries.suffix(7)))
            }

            // Замеры только за сегодня для графика и счетчика
            let startOfToday = Calendar.current.startOfDay(for: Date())
            let todayEntries = allEntries.filter("date >= %@", startOfToday)
            self.entries = Array(todayEntries)
            self.todayCount = todayEntries.count
        }
        
        private func calculateStatus(current: Double, history: [GlucoseEntry]) {
            guard history.count >= 1 else { return }
            let values = history.map { $0.value }
            let average = values.reduce(0, +) / Double(values.count)
            let percentageDiff = (abs(current - average) / average) * 100
            
            if percentageDiff > 80 {
                statusMessage = "Замечено значительное отклонение от ваших обычных показателей. Обратите внимание на самочувствие."
                statusColor = .orange
            } else {
                statusMessage = "Отличная новость! Ваши показатели стабильны."
                statusColor = .black
            }
        }
    }
