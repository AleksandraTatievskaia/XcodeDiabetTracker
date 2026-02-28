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
    
    private var realm: Realm?
    
    init() {
        realm = RealmService.shared.localRealm
        fetchData()
    }
    
    func fetchData() {
        guard let realm = realm else { return }
        
        // 1. Грузим профиль
        if let profile = realm.objects(UserProfile.self).first {
            self.userName = profile.name
            self.glucoseUnit = profile.glucoseUnit
            self.dailyGoal = profile.dailyGoal
        }
        
        // 2. Грузим замеры (сортируем по дате)
        let allEntries = realm.objects(GlucoseEntry.self).sorted(byKeyPath: "date", ascending: true)
        self.entries = Array(allEntries)
        
        if let last = allEntries.last {
            self.lastValue = last.value
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy\nHH:mm"
            self.lastEntryDate = formatter.string(from: last.date)
            
            // 3. Анализируем дельту в замерах
            calculateStatus(current: last.value, history: Array(allEntries.suffix(7)))
        }
    }
    
    private func calculateStatus(current: Double, history: [GlucoseEntry]) {
        // Если замеров мало
        guard history.count >= 3 else {
            statusMessage = "Продолжайте замеры для дальнейших вычислений"
            statusColor = .black
            return
        }
        
        let values = history.map { $0.value }
        let average = values.reduce(0, +) / Double(values.count)
        
        // Считаем разницу в процентах
        let percentageDiff = (abs(current - average) / average) * 100
        
        if percentageDiff > 30 {
            // Если разница больше 30% от привычного уровня
            statusMessage = "Замечено значительное отклонение от ваших обычных показателей. Обратите внимание на самочувствие. Советуем обратиться к врачу"
            statusColor = .orange
        } else {
            // Если все в пределах твоей нормы
            statusMessage = "Отличная новость! Ваши показатели стабильны."
            statusColor = .black
        }
    }
}
