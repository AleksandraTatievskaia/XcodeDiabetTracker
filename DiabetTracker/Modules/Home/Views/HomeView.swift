//
//  HomeView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 24.02.2026.
//

import SwiftUI
import Charts

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // 1. Шапка
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Привет, \(viewModel.userName)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.35, green: 0.34, blue: 0.74))
                    
                    Text("Не забывай заносить сюда информацию о замерах!")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: 220, alignment: .leading)
                }
                
                Spacer()
                
                Button(action: { /* Настройки уведомлений */ }) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5)
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
            
            Spacer(minLength: 15) // Динамический отступ
            
            // 2. Карточка глюкозы
            VStack(spacing: 10) {
                HStack {
                    Text("Глюкоза")
                        .font(.title2.bold())
                    Spacer()
                    Text(viewModel.lastEntryDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                
                Text(String(format: "%.1f", viewModel.lastValue))
                    .font(.system(size: 56, weight: .bold))
                Text(viewModel.glucoseUnit)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.55, green: 0.53, blue: 0.95))
                    .frame(height: 6)
                
                Text(viewModel.statusMessage)
                    .font(.subheadline)
                    .foregroundColor(viewModel.statusColor)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8) // Чтобы текст не вылезал
                    .padding(.top, 2)
            }
            .padding(22)
            .background(Color(red: 0.92, green: 0.91, blue: 1.0))
            .cornerRadius(30)
            .padding(.horizontal)
            
            Spacer(minLength: 15)
            
            // 3. ГРАФИК
            VStack(alignment: .leading, spacing: 10) {
                Text("График за день")
                    .font(.headline)
                    .padding(.horizontal)
                
                Chart {
                    ForEach(viewModel.entries) { entry in
                        LineMark(
                            x: .value("Время", entry.date),
                            y: .value("Сахар", entry.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color(red: 0.35, green: 0.34, blue: 0.74))
                        
                        AreaMark(
                            x: .value("Время", entry.date),
                            y: .value("Сахар", entry.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(LinearGradient(colors: [Color(red: 0.35, green: 0.34, blue: 0.74).opacity(0.2), .clear], startPoint: .top, endPoint: .bottom))
                    }
                }
                .frame(maxHeight: 160) // Адаптивная высота графика
                .padding(15)
                .background(Color.cyan.opacity(0.06))
                .cornerRadius(25)
                .padding(.horizontal)
            }
            
            Spacer(minLength: 15)
            
            // 4. Напоминания о замерах
            HStack {
                Text("За сегодня сделано 0/\(viewModel.dailyGoal) замеров")
                    .font(.system(size: 15, weight: .medium))
                Spacer()
                Button(action: { /* Вызов напоминаний окна */ }) {
                    Image(systemName: "plus")
                        .font(.title3.bold())
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(16)
            .background(Color("Grey"))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.03), radius: 5)
            .padding(.horizontal)
            
            // Отступ под меню
            Spacer(minLength: 100)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
// Блок превью
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


