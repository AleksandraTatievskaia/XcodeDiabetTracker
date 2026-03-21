//
//  EditEntryView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 21.03.2026.
//

import SwiftUI

struct EditEntryView: View {
    let entry: GlucoseEntry
    let onSave: () -> Void

    @StateObject private var viewModel: EditEntryViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isWarningExpanded = false

    private let warningBackground = Color(red: 0.89, green: 0.87, blue: 1.0)

    init(entry: GlucoseEntry, onSave: @escaping () -> Void) {
        self.entry = entry
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: EditEntryViewModel(entry: entry))
    }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Шапка
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("Редактирование")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.35, green: 0.34, blue: 0.74))
                    Text("Глюкоза")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    viewModel.saveEntry {
                        onSave()
                        dismiss()
                    }
                }) {
                    Text("Сохранить")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0.35, green: 0.34, blue: 0.74))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.89, green: 0.87, blue: 1.0))
                        .cornerRadius(20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)

            Divider()

            ScrollView {
                VStack(spacing: 0) {

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

                        AddEntryRow(title: "Заметки") {
                            TextField("Нет", text: $viewModel.note)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 20)

                    VStack(spacing: 4) {
                        TextField("0.0", text: $viewModel.value)
                            .font(.system(size: 64, weight: .bold))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)

                        Text(viewModel.unit)
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                            .padding(.bottom, 16)
                    }

                    Button(action: { isWarningExpanded = true }) {
                        HStack {
                            Text(viewModel.warningMessage)
                                .font(.system(size: 14))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "info.circle")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.95))
                        }
                        .padding(16)
                        .background(warningBackground)
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $isWarningExpanded) {
          
            WarningDetailView(
                message: viewModel.warningMessage,
                isPresented: $isWarningExpanded
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
        }
    }
}

// MARK: - Preview

#Preview {
    let entry = GlucoseEntry()
    entry.value  = 14.2
    entry.date   = Date()
    entry.period = "После обеда"
    entry.note   = "Тестовая заметка"
    return EditEntryView(entry: entry, onSave: {})
}
