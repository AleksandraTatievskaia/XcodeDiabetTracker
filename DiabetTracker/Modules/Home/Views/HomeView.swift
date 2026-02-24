//
//  HomeView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 24.02.2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Добро пожаловать домой!")
                    .font(.title)
                
                Button("Сбросить онбординг (для теста)") {
                    // загулушка
                    UserDefaults.standard.set(false, forKey: "isOnboardingCompleted")
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Главная")
        }
    }
}
