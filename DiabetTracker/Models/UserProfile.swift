//
//  UserProfile.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 11.02.2026.
//

import Foundation
import RealmSwift
// модель для данных пользователя
class UserProfile: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String = "" // Имя
    @Persisted var age: Int = 0 // Возраст
    @Persisted var gender: String = "Мужчина" // Пол
    @Persisted var glucoseUnit: String = "mmol/L" // Единицы измерения
    @Persisted var dailyGoal: Int = 4 // Количество замеров в день
    
    @Persisted var isOnboardingCompleted: Bool = false // Проверка приветствия
}
