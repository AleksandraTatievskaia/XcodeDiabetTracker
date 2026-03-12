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
    @Published var value: String = "" {
            didSet { updateWarning() }
        }
    @Published var date: Date = Date()
    @Published var period: String = "После обеда"
    @Published var unit: String = "ммоль/л" // Подгрузится из базы значение, которые выбрал пользователь
    @Published var note: String = ""
    @Published var warningMessage: String = "Введите значение"
    
    // Списки для выбора
    let periods = ["Натощак", "До завтрака", "После завтрака", "До обеда", "После обеда", "До ужина", "После ужина", "Перед сном"]
    

    init() {
            // Подгружаем единицы измерения из профиля пользователя
            if let realm = RealmService.shared.localRealm,
               let profile = realm.objects(UserProfile.self).first {
                self.unit = profile.glucoseUnit
            }
        }

        private func updateWarning() {
            let normalized = value.replacingOccurrences(of: ",", with: ".")
            guard let val = Double(normalized) else {
                warningMessage = "Ожидание ввода данных..."
                return
            }
            
            // Пороговые значения (ммоль/л)
            let lowLimit: Double = 3.9
            let highLimit: Double = 11.1
            
            // Конвертируем пороги для сравнения, если у пользователя мг/дл
            let currentLow = (unit == "ммоль/л") ? lowLimit : (lowLimit * 18.02)
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

        func saveEntry(completion: @escaping () -> Void) {
            let normalizedValue = value.replacingOccurrences(of: ",", with: ".")
            guard let doubleValue = Double(normalizedValue) else { return }
            
            let newEntry = GlucoseEntry()
            newEntry.value = doubleValue
            newEntry.date = date
            newEntry.period = period
            newEntry.note = note
            
            if let realm = RealmService.shared.localRealm {
                try! realm.write {
                    realm.add(newEntry)
                }
                completion()
            }
        }
    }
