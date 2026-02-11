//
//  DiabetTrackerApp.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 10.02.2026.
//

import SwiftUI

@main
struct GlucoseTrackerApp: App {
    // Проверяем статус онбординга
    @AppStorage("isOnboardingCompleted") var isOnboardingCompleted: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if isOnboardingCompleted {
                Text("Главный экран (в разработке)")
            } else {
                // экран онбординга 
                OnboardingContainerView()
            }
        }
    }
}
