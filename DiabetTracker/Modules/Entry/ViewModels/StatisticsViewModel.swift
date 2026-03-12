//
//  StatisticsViewModel.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 11.03.2026.
//

import Foundation
import RealmSwift
import Combine

enum StatsPeriod: String, CaseIterable {
    case day = "День"
    case week = "Неделя"
    case month = "Месяц"
}

class StatisticsViewModel: ObservableObject {
    @Published var entries: [GlucoseEntry] = []
    @Published var selectedPeriod: StatsPeriod = .day {
        didSet { fetchData() }
    }
    @Published var glucoseUnit: String = "ммоль/л"
    @Published var averageValue: Double = 0.0

    func fetchData() {
        guard let realm = RealmService.shared.localRealm else { return }
        realm.refresh()
        
        // Грузим настройки юнитов
        if let profile = realm.objects(UserProfile.self).first {
            self.glucoseUnit = profile.glucoseUnit
        }

        let allEntries = realm.objects(GlucoseEntry.self).sorted(byKeyPath: "date", ascending: true)
        let now = Date()
        let calendar = Calendar.current

        switch selectedPeriod {
        case .day:
            let startOfToday = calendar.startOfDay(for: now)
            entries = Array(allEntries.filter("date >= %@", startOfToday))
        case .week:
            let startOfWeek = calendar.date(byAdding: .day, value: -7, to: now)!
            entries = Array(allEntries.filter("date >= %@", startOfWeek))
        case .month:
            let startOfMonth = calendar.date(byAdding: .month, value: -1, to: now)!
            entries = Array(allEntries.filter("date >= %@", startOfMonth))
        }
        
        // Считаем среднее для сводки
        if !entries.isEmpty {
            let sum = entries.reduce(0) { $0 + $1.value }
            averageValue = sum / Double(entries.count)
        } else {
            averageValue = 0.0
        }
    }
}
