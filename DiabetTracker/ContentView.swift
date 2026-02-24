//
//  ContentView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 10.02.2026.
//

import SwiftUI

struct ContentView: View {
    // проверяем прошел ли пользователь onboarding
    @AppStorage("isOnboaringCompleted") var isOnboardingCompleted: Bool = false
    var body: some View {
        Group {
            if isOnboardingCompleted {
                // Если регистрация пройдена — показываем главный экран
                HomeView()
            } else {
                // Если нет — показываем твой красивый онбординг
                OnboardingContainerView()
            }
        }
        .animation(.easeInOut, value: isOnboardingCompleted) // Плавный переход
    }
}

