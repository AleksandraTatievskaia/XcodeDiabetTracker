//
//  RealmManager.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 11.02.2026.
//
import Foundation
import RealmSwift

class RealmService {
    static let shared = RealmService()
    var localRealm: Realm?

    init() {
        openRealm()
    }

    func openRealm() {
        do {
            let config = Realm.Configuration(schemaVersion: 1)
            localRealm = try Realm(configuration: config)
        } catch {
            print("Ошибка открытия Realm: \(error)")
        }
    }

    // Сохранение профиля пользователя
    func saveProfile(_ profile: UserProfile) {
        guard let realm = localRealm else { return }
        do {
            try realm.write {
                realm.add(profile)
            }
        } catch {
            print("Ошибка сохранения профиля: \(error)")
        }
    }
}
