//
//  EntriesView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 21.03.2026.
//

import SwiftUI

struct EntriesView: View {
    @StateObject private var viewModel = EntriesViewModel()
    @State private var entryToEdit: GlucoseEntry? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Заголовок
            Text("Внесённые значения")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(red: 0.35, green: 0.34, blue: 0.74))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                .padding(.top, 30)
                .padding(.bottom, 12)

            // Поиск по дате
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 15))
                TextField("Поиск по дате...", text: $viewModel.searchText)
                    .font(.system(size: 15))
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 15))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 4)

            if viewModel.groups.isEmpty {
                emptyState
            } else {
                entriesList
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear { viewModel.fetchData() }
        // Попап редактирования
        .sheet(item: $entryToEdit) { entry in
            EditEntryView(entry: entry) {
                viewModel.fetchData()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
        }
    }

    // MARK: - Пустое состояние

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: viewModel.searchText.isEmpty ? "drop.fill" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.95).opacity(0.3))
            Text(viewModel.searchText.isEmpty ? "Замеров пока нет" : "Ничего не найдено")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.gray)
            Text(viewModel.searchText.isEmpty
                 ? "Добавьте первый замер через кнопку +"
                 : "Попробуйте \"март\", \"21 марта\" или \"пятница\"")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Список

    private var entriesList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.groups) { group in
                    Text(group.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 6)

                    VStack(spacing: 0) {
                        ForEach(Array(group.entries.enumerated()), id: \.element.id) { index, entry in
                            SwipeToDeleteRow {
                                EntryRow(
                                    entry: entry,
                                    unit: viewModel.glucoseUnit,
                                    formattedValue: viewModel.formatValue(entry.value),
                                    isLast: index == group.entries.count - 1
                                )
                                .onTapGesture { entryToEdit = entry }
                            } onDelete: {
                                viewModel.delete(entry: entry)
                            }
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                 
                }

                Color.clear.frame(height: 110)
            }
        }
    }
}

// MARK: - Свайп для удаления

private struct SwipeToDeleteRow<Content: View>: View {
    let content: Content
    let onDelete: () -> Void

    init(@ViewBuilder content: () -> Content, onDelete: @escaping () -> Void) {
        self.content = content()
        self.onDelete = onDelete
    }

    @State private var offset: CGFloat = 0
    private let deleteWidth: CGFloat = 80

    var body: some View {
        content
            .offset(x: offset)
            .background(Color(.systemGray6))
            // Кнопка удаления — overlay справа, точно по высоте строки
            .overlay(alignment: .trailing) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) { offset = 0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { onDelete() }
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: deleteWidth)
                        .frame(maxHeight: .infinity)
                        .background(Color(red: 0.88, green: 0.28, blue: 0.28))
                }
                // Кнопка выезжает справа вместе со смещением контента
                .offset(x: deleteWidth + offset)
            }
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        let drag = min(0, value.translation.width)
                        offset = max(-deleteWidth, drag)
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            offset = value.translation.width < -deleteWidth / 2 ? -deleteWidth : 0
                        }
                    }
            )
    }
}

// MARK: - Строка замера

private struct EntryRow: View {
    let entry: GlucoseEntry
    let unit: String
    let formattedValue: String
    let isLast: Bool

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMM yyyy 'в' HH:mm"
        return f
    }()

    // Цвет значения — как в графике
    private var valueColor: Color {
        let low:  Double = unit == "ммоль/л" ? 3.9  : 3.9  * 18.02
        let high: Double = unit == "ммоль/л" ? 11.1 : 11.1 * 18.02
        if entry.value < low  { return Color(red: 0.95, green: 0.60, blue: 0.20) }
        if entry.value > high { return Color(red: 0.88, green: 0.28, blue: 0.28) }
        return Color(red: 0.35, green: 0.34, blue: 0.74)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                // Цветная полоска слева
                RoundedRectangle(cornerRadius: 2)
                    .fill(valueColor)
                    .frame(width: 3, height: 36)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Глюкоза")
                        .font(.system(size: 15, weight: .semibold))
                    Text(timeFormatter.string(from: entry.date))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(entry.period)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Значение
                Text("\(formattedValue) \(unit)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(valueColor)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            if !isLast {
                Divider()
                    .padding(.leading, 29)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    EntriesView()
}
