//
//  NotificationSetupView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 24.02.2026.
//

import SwiftUI

struct NotificationSetupView: View {
    
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Text("Разрешите отправку уведомлений для напоминаний о замерах глюкозы")
                .font(.system(size: 20, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // для кнопок
            HStack(spacing: 20) {
                // Пропустить
                Button(action: {
                    withAnimation {viewModel.currentStep = 4}
                }) {
                    Text("Пропустить")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(.systemGray5))
                        .cornerRadius(25)
                }
                // Кнопка "Продолжить"
                Button(action: {
                    // Вызываем сервис
                    NotificationService.shared.requestPermission { granted in
                        // идем дальше
                        // но знаем, разрешил ли пользователь доступ
                        withAnimation { viewModel.currentStep = 4 }
                    }
                }) {
                    Text("Продолжить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("MainPurple"))
                        .cornerRadius(25)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct NotificationSetupView_Previews: PreviewProvider {
    static var previews: some View {
        // Создаем временную версию ViewModel для отображения
        NotificationSetupView(viewModel: OnboardingViewModel())
    }
}
