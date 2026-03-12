//
//  AddEntryView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 03.03.2026.
//

import SwiftUI

struct AddEntryView: View {
    @Binding var isShowingAddSheet: Bool
    @Binding var selectedTab: Int

    @StateObject private var viewModel = AddEntryViewModel()
    @Environment(\.dismiss) var dismiss

    private let warningBackground = Color(red: 0.89, green: 0.87, blue: 1.0)

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                VStack(spacing: 5) {
                    Text("Внесение замеров")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 0.35, green: 0.34, blue: 0.74))
                    Text("Глюкоза")
                        .font(.system(size: 26, weight: .bold))
                }
                .padding(.top, 40)

                VStack(spacing: 0) {
                    AddEntryRow(title: "Дата") {
                        HStack {
                            DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                                .labelsHidden()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            DatePicker("", selection: $viewModel.date, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }

                    AddEntryRow(title: "Период") {
                        Menu {
                            ForEach(viewModel.periods, id: \.self) { p in
                                Button(p) { viewModel.period = p }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.period)
                                Image(systemName: "chevron.right.2").font(.caption2)
                            }
                            .foregroundColor(.black)
                        }
                    }

                    AddEntryRow(title: "Единицы измерения") {
                        Text(viewModel.unit).foregroundColor(.gray)
                    }

                    TextField("Заметки", text: $viewModel.note)
                        .font(.system(size: 16))
                        .padding(.vertical, 20)

                    Divider()

                    TextField("0.0", text: $viewModel.value)
                        .font(.system(size: 64, weight: .bold))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 10)

                    Text(viewModel.unit)
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                .padding(.horizontal, 25)

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Информационные предупреждения:")
                        .font(.system(size: 16, weight: .bold))
                    Text(viewModel.warningMessage)
                        .font(.system(size: 14))
                        .lineSpacing(3)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(warningBackground)
                .cornerRadius(20)
                .padding(.horizontal, 25)
                .padding(.bottom, 20)

                Button(action: {
                    viewModel.saveEntry { dismiss() }
                }) {
                    Text("Сохранить")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 0.55, green: 0.53, blue: 0.95))
                        .cornerRadius(28)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 100)
            }
            .background(Color.white.ignoresSafeArea())

            // Таббар
            LiquidTabBar(
                selectedTab: $selectedTab,
                isShowingAddSheet: $isShowingAddSheet
            )
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct AddEntryRow<Content: View>: View {
    let title: String
    let content: Content
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                Spacer()
                content
            }
            .padding(.vertical, 15)
            Divider()
        }
    }
}

#Preview {
    AddEntryView(
        isShowingAddSheet: .constant(true),
        selectedTab: .constant(1)
    )
}
