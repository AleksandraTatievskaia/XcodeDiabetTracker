//
//  AddEntryViewModel.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 03.03.2026.
//
import RealmSwift
import Foundation
import Combine

class AddEntryViewModel: ObservableObject {
    // введенное пользователем значение глюкозы
    @Published var value: String = "" {
        didSet {
            let sanitized = sanitize(value)
            // Если после фильтрации строка изменилась, то заменяем
            if sanitized != value {
                value = sanitized
                return
            }
            updateWarning()
        }
    }
    @Published var date: Date = Date()
    @Published var period: String = "После обеда"
    @Published var unit: String = "ммоль/л"
    @Published var note: String = ""
    // текст предупреждения обновляется при изменении value
    @Published var warningMessage: String = "Введите значение"

    let periods = ["Натощак", "До завтрака", "После завтрака", "До обеда", "После обеда", "До ужина", "После ужина", "Перед сном"]

    init() {
        // подгружаем единицы измерения из профиля
        if let realm = RealmService.shared.localRealm,
           let profile = realm.objects(UserProfile.self).first {
            self.unit = profile.glucoseUnit
        }
    }

    // MARK: - Фильтрация ввода
    // что делаем: заменяем запятую на точку, разрешены только цифры и одна точка
    private func sanitize(_ input: String) -> String {
       
        let normalized = input.replacingOccurrences(of: ",", with: ".")

        // Оставляем только цифры и одну точку
        var result = ""
        var hasDot = false

        for char in normalized {
            if char.isNumber {
                result.append(char)
            } else if char == "." && !hasDot {
                // Точка в самом начале не нужна — добавляем "0." автоматически
                if result.isEmpty { result = "0" }
                result.append(char)
                hasDot = true
            }
            // Всё остальное игнорируем
        }

        // Не больше 2 знаков после точки (0.00)
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
        let normalized = value.replacingOccurrences(of: ",", with: ".")
        guard let val = Double(normalized), !value.isEmpty else {
            warningMessage = "Ожидание ввода данных..."
            return
        }

        let lowLimit: Double  = 3.9
        let highLimit: Double = 11.1
        let currentLow  = (unit == "ммоль/л") ? lowLimit  : (lowLimit  * 18.02)
        let currentHigh = (unit == "ммоль/л") ? highLimit : (highLimit * 18.02)

        if val < currentLow {
            let thresholdStr = (unit == "ммоль/л") ? "3,9 ммоль/л" : "70,278 мг/дл"
            warningMessage = "Уровень глюкозы ниже \(thresholdStr). Это пограничное значение, при котором важно обратить внимание на самочувствие. Рекомендуем обратиться с консультацией к врачу."
        } else if val > currentHigh {
            let thresholdStr = (unit == "ммоль/л") ? "11,1 ммоль/л" : "200,022 мг/дл"
            warningMessage = "Уровень глюкозы выше \(thresholdStr). Это значение может указывать на риск осложнений. Обратите внимание на самочувствие. Рекомендуем обратиться с консультацией к врачу."
        } else {
            warningMessage = "Показатель в пределах нормы."
        }
    }

    // MARK: - Сохранение
    // создаем новую запись и сохраняем ее в БД
    func saveEntry(completion: @escaping () -> Void) {
        let normalizedValue = value.replacingOccurrences(of: ",", with: ".")
        guard let doubleValue = Double(normalizedValue) else { return }

        let newEntry = GlucoseEntry()
        newEntry.value = doubleValue
        newEntry.date  = date
        newEntry.period = period
        newEntry.note  = note

        if let realm = RealmService.shared.localRealm {
            try! realm.write {
                realm.add(newEntry)
            }
            completion() // после успешной записи закрываем View
        }
    }
}
