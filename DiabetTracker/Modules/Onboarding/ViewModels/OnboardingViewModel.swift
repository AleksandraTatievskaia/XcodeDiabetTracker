//
//  Untitled.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 11.02.2026.
//

import SwiftUI
import RealmSwift
import Combine

class OnboardingViewModel: ObservableObject {
    // Поля для заполнения
    @Published var name: String = ""
    @Published var age: String = ""
    @Published var selectedGender: String = "Мужчина"
    @Published var selectedUnit: String = "mmol/L"
    @Published var dailyGoal: Int = 4
    
    // Состояние навигации
    @Published var currentStep: Int = 1
    @Published var isAgreed: Bool = false
    
    func finishOnboarding() {
        let profile = UserProfile()
        profile.name = name
        profile.age = Int(age) ?? 0
        profile.gender = selectedGender
        profile.glucoseUnit = selectedUnit
        profile.dailyGoal = dailyGoal
        profile.isOnboardingCompleted = true
        
        RealmService.shared.saveProfile(profile)
        
        // Помечаем в настройках устройства, что онбординг пройден
        UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
    }
}
