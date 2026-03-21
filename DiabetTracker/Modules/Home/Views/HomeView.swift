//
//  HomeView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 24.02.2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Binding var isShowingAddSheet: Bool // Связь для открытия экрана
    
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
            
            Spacer(minLength: 15)
            
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
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
            .padding(22)
            .background(Color(red: 0.92, green: 0.91, blue: 1.0))
            .cornerRadius(30)
            .padding(.horizontal)
            
            Spacer(minLength: 15)
            
            // 3. ГРАФИК
            // Фиксированная высота — столбики не могут вырасти выше этой области
            // Текст пустого состояния: "за сегодня" т.к. entries фильтруются по сегодняшнему дню
            GlucoseChartView(
                entries: viewModel.entries,
                glucoseUnit: viewModel.glucoseUnit,
                emptyStateText: "Нет замеров за сегодня"
            )
            .padding(.horizontal)
            .frame(height: 200)

            Spacer(minLength: 15)
            
            // 4. Напоминания о замерах
            HStack {
                Text("За сегодня сделано \(viewModel.todayCount)/\(viewModel.dailyGoal) замеров")
                    .font(.system(size: 15, weight: .medium))
                Spacer()
                Button(action: { isShowingAddSheet = true }) {
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
            
            Spacer(minLength: 100)
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear { viewModel.fetchData() }
        .onChange(of: isShowingAddSheet) { oldValue, newValue in
            if newValue == false {
                viewModel.fetchData()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(isShowingAddSheet: .constant(false))
    }
}
