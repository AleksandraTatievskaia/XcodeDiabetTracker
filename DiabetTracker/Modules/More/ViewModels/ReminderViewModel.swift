//
//  ReminderViewModel.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 25.03.2026.
//
//

import Foundation
import RealmSwift
import UserNotifications
import Combine
import Realm

class ReminderViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []

    private var realm: Realm?

    init() {
        realm = RealmService.shared.localRealm
        fetchReminders()
    }

    func fetchReminders() {
        guard let realm = RealmService.shared.localRealm else { return }
        realm.refresh()

        let results = realm.objects(Reminder.self).sorted(byKeyPath: "time")
        self.reminders = Array(results)
    }

    func addReminder(title: String, time: Date, repeatDaily: Bool) {
        guard let realm = RealmService.shared.localRealm else { return }

        let reminder = Reminder()
        reminder.title = title
        reminder.time = time
        reminder.repeatDays = repeatDaily
        reminder.isEnabled = true

        try! realm.write {
            realm.add(reminder)
        }

        scheduleNotification(for: reminder)
        fetchReminders()
    }

    func deleteReminder(_ reminder: Reminder) {
        guard let realm = RealmService.shared.localRealm else { return }

        cancelNotification(for: reminder)

        try! realm.write {
            realm.delete(reminder)
        }

        fetchReminders()
    }

    func toggleReminder(_ reminder: Reminder) {
        guard let realm = RealmService.shared.localRealm else { return }

        try! realm.write {
            reminder.isEnabled.toggle()
        }

        if reminder.isEnabled {
            scheduleNotification(for: reminder)
        } else {
            cancelNotification(for: reminder)
        }

        fetchReminders()
    }

    // MARK: - Local Notifications

    private func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: reminder.repeatDays
        )

        let request = UNNotificationRequest(
            identifier: reminder.id.stringValue,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification(for reminder: Reminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [reminder.id.stringValue]
        )
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}
