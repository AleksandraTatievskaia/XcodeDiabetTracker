//
//  EditEntryViewModel.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 21.03.2026.
//

import Foundation
import RealmSwift
import SwiftUI
import Combine

class EditEntryViewModel: ObservableObject {
    @Published var value: String = "" {
        didSet {
            let sanitized = sanitize(value)
            if sanitized != value {
                value = sanitized
                return
            }
            updateWarning()
        }
    }
    @Published var date: Date = Date()
    @Published var period: String = "После обеда"
    @Published var note: String = ""
    @Published var unit: String = "ммоль/л"
    @Published var warningMessage: String = ""

    let periods = ["Натощак", "До завтрака", "После завтрака", "До обеда", "После обеда", "До ужина", "После ужина", "Перед сном"]

    // ID записи для поиска в Realm при сохранении
    private var entryID: ObjectId?

    init(entry: GlucoseEntry) {
        if let realm = RealmService.shared.localRealm,
           let profile = realm.objects(UserProfile.self).first {
            self.unit = profile.glucoseUnit
        }
        self.entryID = entry.id
        self.date    = entry.date
        self.period  = entry.period
        self.note    = entry.note
        // Форматируем значение под текущие единицы
        self.value   = unit == "мг/дл"
            ? String(format: "%.0f", entry.value)
            : String(format: "%.1f", entry.value)
        updateWarning()
    }

    // MARK: - Фильтрация ввода (идентично AddEntryViewModel)

    private func sanitize(_ input: String) -> String {
        let normalized = input.replacingOccurrences(of: ",", with: ".")
        var result = ""
        var hasDot = false
        for char in normalized {
            if char.isNumber {
                result.append(char)
            } else if char == "." && !hasDot {
                if result.isEmpty { result = "0" }
                result.append(char)
                hasDot = true
            }
        }
        if let dotIndex = result.firstIndex(of: ".") {
            let decimals = result[result.index(after: dotIndex)...]
            if decimals.count > 2 {
                result = String(result.prefix(result.distance(from: result.startIndex, to: dotIndex) + 3))
            }
        }
        return result
    }

    // MARK: - Предупреждение

    private func updateWarning() {
        guard let val = Double(value.replacingOccurrences(of: ",", with: ".")), !value.isEmpty else {
            warningMessage = "Ожидание ввода данных..."
            return
        }
        let low:  Double = unit == "ммоль/л" ? 3.9  : 3.9  * 18.02
        let high: Double = unit == "ммоль/л" ? 11.1 : 11.1 * 18.02
        if val < low {
            let t = unit == "ммоль/л" ? "3,9 ммоль/л" : "70,278 мг/дл"
            warningMessage = "Уровень глюкозы ниже \(t). Рекомендуем обратиться с консультацией к врачу."
        } else if val > high {
            let t = unit == "ммоль/л" ? "11,1 ммоль/л" : "200,022 мг/дл"
            warningMessage = "Уровень глюкозы выше \(t). Рекомендуем обратиться с консультацией к врачу."
        } else {
            warningMessage = "Показатель в пределах нормы."
        }
    }

    // MARK: - Сохранение

    func saveEntry(completion: @escaping () -> Void) {
        let normalized = value.replacingOccurrences(of: ",", with: ".")
        guard let doubleValue = Double(normalized),
              let id = entryID,
              let realm = RealmService.shared.localRealm,
              let entry = realm.object(ofType: GlucoseEntry.self, forPrimaryKey: id)
        else { return }

        try? realm.write {
            entry.value  = doubleValue
            entry.date   = date
            entry.period = period
            entry.note   = note
        }
        completion()
    }
}
