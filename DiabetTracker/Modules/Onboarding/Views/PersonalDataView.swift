//
//  PersonalDataView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 11.02.2026.
//
import Foundation
import SwiftUI

struct PersonalDataView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Расскажите о себе")
                    .font(.largeTitle).bold()
                    .padding(.top)
                
                Text("Эти данные помогут нам настроить приложение под ваши потребности.")
                    .foregroundColor(.gray)
                
                VStack(spacing: 15) {
                    CustomInputField(icon: "person.fill", title: "Ваше имя", text: $viewModel.name)
                    
                    CustomInputField(icon: "birthday.cake.fill", title: "Ваш возраст", text: $viewModel.age)
                        .keyboardType(.numberPad)
                    
                }
                
                // Выбор единиц измерения (как на твоем скрине)
                Text("Единицы измерения")
                    .font(.headline)
                    .padding(.top)
                
                Picker("Единицы", selection: $viewModel.selectedUnit) {
                    Text("mmol/L").tag("mmol/L")
                    Text("mg/dL").tag("mg/dL")
                }
                .pickerStyle(.segmented)
                
                Spacer(minLength: 30)
                
                Button(action: {
                    viewModel.finishOnboarding()
                }) {
                    Text("Начать работу")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(viewModel.name.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(16)
                }
                .disabled(viewModel.name.isEmpty)
            }
            .padding()
        }
    }
}

// для дизайна
struct CustomInputField: View {
    let icon: String
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title).font(.caption).foregroundColor(.gray)
                TextField("Введите...", text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
// Блок превью
struct PersonalDataView_Previews: PreviewProvider {
    static var previews: some View {
    
        PersonalDataView(viewModel: OnboardingViewModel())
    }
}
