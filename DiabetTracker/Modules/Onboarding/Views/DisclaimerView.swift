//
//  DisclaimerView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 11.02.2026.
//

import SwiftUI
import Foundation

struct DisclaimerView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 25) {
            // Заголовок
            Text("Важное уведомление")
                .font(.title2)
                .bold()
                .padding(.top, 40)
            
            // Иконка предупреждения
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
            
            // Текст дисклеймера
            ScrollView {
                Text("Данное приложение предназначено исключительно для самоконтроля уровня глюкозы. \n\nПриложение не является медицинским изделием и не заменяет профессиональную медицинскую консультацию, диагностику или лечение. \n\nВсегда консультируйтесь со своим лечащим врачом перед принятием любых медицинских решений.")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
            }
            
            // Чекбокс (Toggle)
            Toggle(isOn: $viewModel.isAgreed) {
                Text("Я согласен с условиями использования и понимаю риски")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .toggleStyle(CheckboxToggleStyle()) // Используем кастомный стиль
            .padding(.horizontal)

            Spacer()
            
            // Кнопка продолжить
            Button(action: {
                withAnimation {
                    viewModel.currentStep = 3 // Переходим к уведомлениям
                }
            }) {
                Text("Продолжить")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(viewModel.isAgreed ? Color.blue : Color.gray) // Меняем цвет если не нажато
                    .cornerRadius(16)
            }
            .disabled(!viewModel.isAgreed) // Блокируем кнопку
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .padding()
    }
}

// Кастомный стиль для чекбокса
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(configuration.isOn ? .blue : .gray)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}
