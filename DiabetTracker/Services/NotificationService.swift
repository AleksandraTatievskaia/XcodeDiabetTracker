//
//  NotificationService.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 24.02.2026.
//
import UserNotifications
import Foundation

class NotificationService {
    static let shared = NotificationService()
    private init() {}
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        // Запрос прав на звуки, баннеры и наклейку
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            // ответ в фоновом потоке
            DispatchQueue.main.async { // возвращаемся в главный поток после ответа в фоновом
                if let error = error {
                    print("Ошибка запроса: \(error.localizedDescription)")
                    
                }
                completion(granted)
            }
        }
    }
}
