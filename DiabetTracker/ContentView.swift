//
//  ContentView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 10.02.2026.
//

import SwiftUI

struct ContentView: View {
    // проверяем прошел ли пользователь onboarding
    // если значение true, то экран переключается сразу
    @AppStorage("isOnboardingCompleted") var isOnboardingCompleted: Bool = false
    
    var body: some View {
        ZStack {
            if isOnboardingCompleted {
                // Если регистрация пройдена, тогда показываем главный экран
                MainView()
            } else {
                // Если нет онбординг
                OnboardingContainerView()
            }
        }
        .animation(.easeInOut, value: isOnboardingCompleted) // плавный переход
    }
}

