//
//  OnboardingContainerView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 11.02.2026.
//
import SwiftUI
import Foundation


struct OnboardingContainerView: View {
    @StateObject var viewModel = OnboardingViewModel()
    
    var body: some View {
  
        ZStack {
            if viewModel.currentStep == 1 {
                WelcomeView(viewModel: viewModel)
                    .transition(.opacity)
            } else if viewModel.currentStep == 2 {
                DisclaimerView(viewModel: viewModel)
                    .transition(.move(edge: .trailing))
//            } else if viewModel.currentStep == 3 {
//                // Когда  NotificationSetupView, заменить это:
//                NotificationSetupView(viewModel: viewModel)
//                    .transition(.move(edge: .trailing))
            } else if viewModel.currentStep == 4 {
                // будущий экран ввода данных
                Text("Экран ввода данных")
            }
        }
        .animation(.default, value: viewModel.currentStep) // анимацию смены шагов
    }
}
// Блок превью
struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        // Создаем временную версию ViewModel для отображения
        OnboardingContainerView(viewModel: OnboardingViewModel())
    }
}

