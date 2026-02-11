//
//  WelcomeView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 11.02.2026.
//
import Foundation
import SwiftUI


struct WelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        // GeometryReader чтобы динамически определить размер экрана
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Верхняя часть с волной
                ZStack(alignment: .bottomTrailing) { // Смещаем содержимое ZStack вниз и вправо
                    WaveHeaderShape()
                        .fill(Color("MainPurple"))
                        .ignoresSafeArea()
                    
                    // Заголовок
                    VStack(alignment: .leading) {
                        Text("Возьмите здоровье\nпод контроль")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 24)
                            .padding(.top, 60)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
 
                    ZStack {
                        Image("WelcomeImage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                    }
                    .offset(x: -20, y: 50) // Смещаем круг вправо (-x при alignment .bottomTrailing) и вниз
                }
                .frame(height: geometry.size.height * 0.53) // сколько от высоты экрана занимает
                
                Spacer(minLength: 70)
                
                // Текстовый блок
                VStack(spacing: 18) {
                    Text("Это приложение помогает вести дневник уровня глюкозы, отслеживать динамику и формировать отчёты для врача")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Кнопка продолжить
                Button(action: {
                    withAnimation { viewModel.currentStep = 2 }
                }) {
                    Text("Продолжить")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color("MainPurple"))
                        .cornerRadius(18)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
    }
}
// Блок превью
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(viewModel: OnboardingViewModel())
    }
}   
