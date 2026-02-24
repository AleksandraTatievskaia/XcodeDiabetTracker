//
//  OnBoardingViewModel.swift
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
    
    @Published var showNameAlert: Bool = false
    
    func finishOnboarding() {
        
        guard isNameValid else {
            showNameAlert = true
            return
        }
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
    
    var ageSuffix: String {
        guard let n = Int(age) else { return "лет" }
        let mod100 = n % 100
        let mod10 = n % 10
        if mod100 >= 11 && mod100 <= 14 { return "лет" }
        switch mod10 {
        case 1: return "год"
        case 2, 3, 4: return "года"
        default: return "лет"
        }
    }
    
    var isNameValid: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed.allSatisfy({ $0.isLetter || $0.isWhitespace })
    }

    var isFormValid: Bool {
        let ageValue = Int(age) ?? 0
        return isNameValid && ageValue > 0 && ageValue < 120
    }
    
}

