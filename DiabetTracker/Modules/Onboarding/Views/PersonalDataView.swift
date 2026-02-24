//
//  PersonalDataView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 11.02.2026.
//
import SwiftUI
import Foundation

// MARK: АНКЕТА
struct ProfileRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: Content

    init(icon: String, iconColor: Color, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(iconColor.opacity(0.2)) // цветной фон
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 20, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Элемент ввода (TextField, Picker или Text)
                content
            }
            .padding(.vertical, 12)
            
            Divider()
                .padding(.leading, 60) // Линия начинается после иконки
        }
    }
}

// MARK: - Основной экран анкеты
struct PersonalDataView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // 1. Заголовочная часть
            VStack(alignment: .leading, spacing: 12) {
                Text("Расскажите о себе")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color(red: 0.35, green: 0.34, blue: 0.74)) // Фирменный индиго
                
                Text("Ваши индивидуальные параметры помогут для дальнейшей персонализации")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 30)
            
            // 2. Список параметров (Анкета)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Имя
                    ProfileRow(icon: "pencil.line", iconColor: .blue, title: "Ваше имя") {
                        TextField("Введите", text: $viewModel.name)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                    }
                    
                    // Возраст (с иконкой торта, как в макете)
                    ProfileRow(icon: "birthday.cake", iconColor: .cyan, title: "Ваш возраст") {
                        HStack(spacing: 5) {
                            TextField("0", text: $viewModel.age)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 40)
                            Text(viewModel.ageSuffix)
                        }
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                    }
                    
                    // Пол
                    ProfileRow(icon: "person.fill", iconColor: .orange, title: "Ваш пол") {
                        Picker("", selection: $viewModel.selectedGender) {
                            Text("Мужчина").tag("Мужчина")
                            Text("Женщина").tag("Женщина")
                        }
                        .pickerStyle(.menu)
                        .accentColor(.black)
                        .fontWeight(.semibold)
                    }
                    
                    // Единицы измерения
                    ProfileRow(icon: "doc.plaintext.fill", iconColor: .blue, title: "Единицы измерения") {
                        Menu {
                            Button("mmol/L") { viewModel.selectedUnit = "ммоль/л" }
                            Button("mg/dL") { viewModel.selectedUnit = "мг/дл" }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                                Text(viewModel.selectedUnit)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.35, green: 0.34, blue: 0.74))
                            }
                        }
                    }
                    
                    // Количество замеров
                    ProfileRow(icon: "checkmark.seal.fill", iconColor: .purple, title: "Замеров в день") {
                        Stepper("", value: $viewModel.dailyGoal, in: 1...10)
                            .labelsHidden()
                        Text("\(viewModel.dailyGoal)")
                            .fontWeight(.semibold)
                            .frame(width: 25)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // 3. Кнопка завершения
            Button(action: {
                viewModel.finishOnboarding()
            }) {
                
                Text("Продолжить")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(
                        viewModel.isFormValid ? Color(red: 0.55, green: 0.53, blue: 0.95) : Color.gray.opacity(0.3)
                    )                    .cornerRadius(20)
            }
            .disabled(!viewModel.isFormValid)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.white.ignoresSafeArea())
        .alert("Некорректное имя", isPresented: $viewModel.showNameAlert) {
                    Button("Понятно", role: .cancel) { }
                } message: {
                    Text("Имя должно содержать только буквы. Например, «Анна» или «Иван».")
                }
    }
}
// Блок превью
struct PersonalDataView_Previews: PreviewProvider {
    static var previews: some View {
    
        PersonalDataView(viewModel: OnboardingViewModel())
    }
}
