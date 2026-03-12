//
//  StatisticsView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 11.03.2026.
//

import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Заголовок
                Text("Статистика")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.35, green: 0.34, blue: 0.74))
                    .padding(.horizontal)
                    .padding(.top, 15)

                // Переключатель периодов
                Picker("Период", selection: $viewModel.selectedPeriod) {
                    ForEach(StatsPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Сводка
                HStack(spacing: 15) {
                    StatCard(title: "Средний сахар",
                             value: String(format: "%.1f", viewModel.averageValue),
                             subtitle: viewModel.glucoseUnit)
                    StatCard(title: "Замеров",
                             value: "\(viewModel.entries.count)",
                             subtitle: "всего")
                }
                .padding(.horizontal)

                // График
                VStack(alignment: .leading, spacing: 10) {
                    Text("График показателей")
                        .font(.headline)
                        .padding(.horizontal)

                    GlucoseChartView(
                        entries: viewModel.entries,
                        glucoseUnit: viewModel.glucoseUnit,
                        showDate: viewModel.selectedPeriod != .day
                    )
                    .padding(.horizontal)
                    .frame(height: 500)
                }

                Spacer(minLength: 100)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear { viewModel.fetchData() }
    }
}

// MARK: - Вспомогательная карточка сводки

private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2.bold())
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - Preview

#Preview {
    StatisticsView()
}
