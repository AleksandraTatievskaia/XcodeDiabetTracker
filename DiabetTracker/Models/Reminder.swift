//
//  Reminder.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 25.03.2026.
//

import Foundation
import RealmSwift

// модель для напоминаний о замерах
class Reminder: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var time: Date = Date() // Время срабатывания уведомления
    @Persisted var title: String = "" // Заголовок уведомления
    @Persisted var isEnabled: Bool = true // Активно ли напоминание
    @Persisted var repeatDays: Bool = true // Повторять ежедневно
    // Связь с UserProfile — добавить если появится
    // переключение пользователей
}
    
