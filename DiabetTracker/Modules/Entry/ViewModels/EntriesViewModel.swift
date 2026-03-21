//
//  EntriesViewModel.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 21.03.2026.
//

import Foundation
import RealmSwift
import SwiftUI
import Combine

// Группа замеров за один день
struct EntriesGroup: Identifiable {
    let id: Date        // startOfDay как ключ
    let title: String   // Как пример, "Пятница, 30 января 2026"
    let entries: [GlucoseEntry]
}

class EntriesViewModel: ObservableObject {
    @Published var groups: [EntriesGroup] = []
    @Published var glucoseUnit: String = "ммоль/л"
    @Published var searchText: String = "" {
        didSet { applyFilter() }
    }

    // Все группы без фильтра - храним отдельно
    private var allGroups: [EntriesGroup] = []

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "EEEE, d MMMM yyyy"
        return f
    }()

    func fetchData() {
        guard let realm = RealmService.shared.localRealm else { return }
        realm.refresh()

        if let profile = realm.objects(UserProfile.self).first {
            self.glucoseUnit = profile.glucoseUnit
        }

        let all = realm.objects(GlucoseEntry.self)
            .sorted(byKeyPath: "date", ascending: false)

        let calendar = Calendar.current
        var grouped: [Date: [GlucoseEntry]] = [:]
        for entry in all {
            let day = calendar.startOfDay(for: entry.date)
            grouped[day, default: []].append(entry)
        }

        allGroups = grouped
            .sorted { $0.key > $1.key }
            .map { day, entries in
                let raw = dayFormatter.string(from: day)
                let title = raw.prefix(1).uppercased() + raw.dropFirst()
                return EntriesGroup(
                    id: day,
                    title: title,
                    entries: entries.sorted { $0.date > $1.date }
                )
            }

        applyFilter()
    }

    // Фильтрация по заголовку группы (дате)
    // Ищем подстроку без учёта регистра
    // Пример: "21 марта" найдёт "Пятница, 21 марта 2026"
    private func applyFilter() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        if query.isEmpty {
            groups = allGroups
        } else {
            groups = allGroups.filter { group in
                group.title.localizedCaseInsensitiveContains(query)
            }
        }
    }

    func delete(entry: GlucoseEntry) {
        guard let realm = RealmService.shared.localRealm else { return }
        // Realm-объект нужно удалять внутри транзакции
        // Ищем по первичному ключу 
        guard let live = realm.object(ofType: GlucoseEntry.self, forPrimaryKey: entry.id) else { return }
        try? realm.write {
            realm.delete(live)
        }
        fetchData()
    }

    func formatValue(_ value: Double) -> String {
        glucoseUnit == "мг/дл"
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}
