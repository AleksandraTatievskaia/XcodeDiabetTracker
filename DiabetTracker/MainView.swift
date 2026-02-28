//
//  MainView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 28.02.2026.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // фон для всего приложения
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            // Контент страниц
            VStack {
                if selectedTab == 0 {
                    HomeView()
                } else if selectedTab == 2 {
                    Text("Экран статистики")
                } else if selectedTab == 4 {
                    Text("Настройки ")
                } else {
                    Text("еще")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // нижнее меню навигация
            LiquidTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Вспомогательный элемент для размытия
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { uiView.effect = effect }
}

struct LiquidTabBar: View {
    @Binding var selectedTab: Int
    let icons = ["house.fill", "plus.circle.fill", "chart.bar.fill", "doc.text.fill", "gearshape.fill"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<icons.count, id: \.self) { index in
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    ZStack {
                        if selectedTab == index {
                            Circle()
                                .fill(Color(red: 0.55, green: 0.53, blue: 0.95).opacity(0.15))
                                .frame(width: 45, height: 45)
                                .transition(.scale)
                        }
                        
                        Image(systemName: icons[index])
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(selectedTab == index ? Color(red: 0.35, green: 0.34, blue: 0.74) : .gray.opacity(0.5))
                    }
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
}
