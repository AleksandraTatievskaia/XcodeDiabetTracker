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

    @State private var isWarningExpanded = false
    @State private var isKeyboardVisible = false

    private let warningBackground = Color(red: 0.89, green: 0.87, blue: 1.0)

    var body: some View {
        ZStack(alignment: .bottom) {

            Color.white.ignoresSafeArea()

            // ScrollView двигает контент вверх когда появляется клавиатура
            ScrollView {
                VStack(spacing: 0) {

                    // MARK: - Шапка с крестиком
                    HStack {
                        Button(action: { isShowingAddSheet = false }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

                    VStack(spacing: 5) {
                        Text("Внесение замеров")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(red: 0.35, green: 0.34, blue: 0.74))
                        Text("Глюкоза")
                            .font(.system(size: 26, weight: .bold))
                    }
                    .padding(.top, 10)

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

                    Spacer(minLength: 20)

                    // MARK: - Блок предупреждения
                    Button(action: { isWarningExpanded = true }) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Информационные предупреждения:")
                                    .font(.system(size: 16, weight: .bold))
                                Spacer()
                                Image(systemName: "info.circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.95))
                            }
                            Text(viewModel.warningMessage)
                                .font(.system(size: 14))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundColor(.primary)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(warningBackground)
                        .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 16)

                    // MARK: - Кнопка сохранить
                    Button(action: {
                        viewModel.saveEntry { dismiss() }
                    }) {
                        Text("Сохранить")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("MainPurple"))
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 25)
                    // Отступ снизу = высота таббара чтобы кнопка не перекрывалась им
                    .padding(.bottom, 110)
                }
            }
            // Тап по фону вне полей – убирает клавиатуру
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }

            // Таббар — скрывается когда активна клавиатура
            if !isKeyboardVisible {
                LiquidTabBar(
                    selectedTab: $selectedTab,
                    isShowingAddSheet: $isShowingAddSheet
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isKeyboardVisible)
        // Подписываемся на системные уведомления о клавиатуре
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
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

// MARK: - Попап с полным текстом предупреждения

struct WarningDetailView: View {
    let message: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.95))
                        .font(.system(size: 20))
                    Text("Предупреждение")
                        .font(.system(size: 18, weight: .bold))
                }
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            Divider()
            Text(message)
                .font(.system(size: 16))
                .lineSpacing(5)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(24)
        .background(Color.white)
    }
}

// MARK: - Строка формы

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
