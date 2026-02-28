//
//  GlucoseReading.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 11.02.2026.
//
import Foundation
import RealmSwift

// модель для замеров глюкозы
class GlucoseEntry: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var value: Double = 0.0 // Значение глюкозы
    @Persisted var date: Date = Date() // Дата замера
    @Persisted var period: String = "После еды" // Время замера
    @Persisted var note: String = "" // Заметки
}
