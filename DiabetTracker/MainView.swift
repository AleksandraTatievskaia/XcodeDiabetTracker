//
//  MainView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 28.02.2026.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 0
    @State private var isShowingAddSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack {
                if selectedTab == 0 {
                    HomeView(isShowingAddSheet: $isShowingAddSheet)
                } else if selectedTab == 2 {
                    StatisticsView()
                } else if selectedTab == 4 {
                    Text("Настройки")
                } else {
                    Text("еще")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            LiquidTabBar(
                selectedTab: $selectedTab,
                isShowingAddSheet: $isShowingAddSheet
            )
        }
        .fullScreenCover(isPresented: $isShowingAddSheet) {
            AddEntryView(
                isShowingAddSheet: $isShowingAddSheet,
                selectedTab: $selectedTab
            )
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Blur
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { uiView.effect = effect }
}

// MARK: - Tab Bar
struct LiquidTabBar: View {
    @Binding var selectedTab: Int
    @Binding var isShowingAddSheet: Bool
    var activeTabOverride: Int? = nil

    let icons = ["house.fill", "plus.circle.fill", "chart.bar.fill", "doc.text.fill", "gearshape.fill"]

    private func isActive(_ index: Int) -> Bool {
        // Если sheet открыт — подсвечиваем "+" (index 1)
        if isShowingAddSheet { return index == 1 }
        return (activeTabOverride ?? selectedTab) == index
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<icons.count, id: \.self) { index in
                Spacer()
                Button(action: {
                    handleTap(index: index)
                }) {
                    ZStack {
                        if isActive(index) {
                            Circle()
                                .fill(Color(red: 0.55, green: 0.53, blue: 0.95).opacity(0.15))
                                .frame(width: 45, height: 45)
                        }
                        Image(systemName: icons[index])
                            .font(.system(size: index == 1 ? 28 : 22, weight: .medium))
                            .foregroundColor(
                                isActive(index)
                                    ? Color(red: 0.35, green: 0.34, blue: 0.74)
                                    : .gray.opacity(0.5)
                            )
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive(index))
                }
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    private func handleTap(index: Int) {
        if index == 1 {
            // Кнопка "+" — открыть/закрыть AddEntry
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isShowingAddSheet = true
            }
        } else {
            // Любой другой таб — сначала закрыть sheet, потом переключить
            if isShowingAddSheet {
                isShowingAddSheet = false
                // Небольшая задержка, чтобы sheet успел закрыться до смены таба
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = index
                }
            }
        }
    }
}
