//
//  GlucoseChartView.swift
//  DiabetTracker
//
//  Created by Александра Татиевская on 11.03.2026.
//

import SwiftUI

struct GlucoseChartView: View {
    let entries: [GlucoseEntry]
    let glucoseUnit: String
    var showDate: Bool = false  // false = HH:mm, true = dd.MM

    // Выбранный столбик
    @State private var selectedIndex: Int? = nil

    // MARK: - Пороговые значения (единые с AddEntryViewModel)

    private let lowLimitMmol:  Double = 3.9
    private let highLimitMmol: Double = 11.1

    private var lowLimit: Double {
        glucoseUnit == "ммоль/л" ? lowLimitMmol : lowLimitMmol * 18.02
    }
    private var highLimit: Double {
        glucoseUnit == "ммоль/л" ? highLimitMmol : highLimitMmol * 18.02
    }

    // MARK: - Шкала Y
    // Фиксированный максимум — столбики которые превышают его просто обрезаются .clipped()
    private var yMax: Double {
        glucoseUnit == "мг/дл" ? 250 : 15
    }

    private var ySteps: [Double] {
        glucoseUnit == "мг/дл"
            ? [0, 50, 100, 150, 200, 250]
            : [0, 3, 6, 9, 12, 15]
    }

    // MARK: - Форматирование

    private func xLabel(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = showDate ? "dd.MM" : "HH:mm"
        return fmt.string(from: date)
    }

    private func tooltipDate(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd.MM.yyyy HH:mm"
        return fmt.string(from: date)
    }

    private func barColor(for value: Double) -> Color {
        if value < lowLimit {
            return Color(red: 0.95, green: 0.60, blue: 0.20)
        } else if value > highLimit {
            return Color(red: 0.88, green: 0.28, blue: 0.28)
        } else {
            return Color(red: 0.35, green: 0.34, blue: 0.74)
        }
    }

    private func formatValue(_ value: Double) -> String {
        glucoseUnit == "мг/дл"
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if entries.isEmpty {
                emptyState
            } else {
                chart
            }
        }
    }

    // MARK: - Пустое состояние

    // Текст передаётся снаружи
    // HomeView передаёт "за сегодня", StatisticsView — "за выбранный период"
    var emptyStateText: String = "Нет замеров за выбранный период"

    private var emptyState: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.97, green: 0.97, blue: 1.0))

            VStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 32))
                    .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.95).opacity(0.4))
                Text(emptyStateText)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 200)
    }

    // MARK: - График

    // чтобы не обрезался .clipped())
    private struct TooltipInfo {
        let value: Double
        let date: Date
        let xCenter: CGFloat
        let yTop: CGFloat
        let leftPadding: CGFloat
        let plotW: CGFloat
        let topPadding: CGFloat
    }

    private var chart: some View {
        GeometryReader { geo in
            let leftPadding: CGFloat   = 42
            let rightPadding: CGFloat  = 12
            let topPadding: CGFloat    = 24
            let bottomPadding: CGFloat = 32

            let plotW = geo.size.width  - leftPadding - rightPadding
            let plotH = geo.size.height - topPadding  - bottomPadding

            let labelStep = max(1, entries.count / 6)
            let barCount  = entries.count
            let totalGap  = plotW * 0.35
            // Ограничиваем максимальную ширину столбика — при 1-2 замерах он не будет огромным
            let barWidth  = min(32, max(6, (plotW - totalGap) / CGFloat(barCount)))
            let spacing: CGFloat = barCount > 1
                ? (plotW - barWidth * CGFloat(barCount)) / CGFloat(barCount - 1)
                : 0

            // Считаем данные тултипа для overlay
            let tooltipInfo: TooltipInfo? = {
                guard let idx = selectedIndex, idx < entries.count else { return nil }
                let entry = entries[idx]
                let xCenter = leftPadding + barWidth / 2 + CGFloat(idx) * (barWidth + spacing)
                let barH = max(4, plotH * CGFloat(entry.value / yMax))
                let yBottom = topPadding + plotH
                let yTop = yBottom - barH
                return TooltipInfo(
                    value: entry.value,
                    date: entry.date,
                    xCenter: xCenter,
                    yTop: yTop,
                    leftPadding: leftPadding,
                    plotW: plotW,
                    topPadding: topPadding
                )
            }()

            ZStack(alignment: .topLeading) {

                // Фон
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.97, green: 0.97, blue: 1.0))
                    .shadow(color: Color(red: 0.55, green: 0.53, blue: 0.95).opacity(0.10),
                            radius: 8, x: 0, y: 3)

                // Зелёная зона нормы
                let normYTop    = topPadding + plotH * CGFloat(1 - highLimit / yMax)
                let normYBottom = topPadding + plotH * CGFloat(1 - lowLimit  / yMax)

                Rectangle()
                    .fill(Color.green.opacity(0.08))
                    .frame(width: plotW, height: max(0, normYBottom - normYTop))
                    .position(x: leftPadding + plotW / 2,
                              y: (normYTop + normYBottom) / 2)

                // Линия нижнего порога
                Path { path in
                    path.move(to:    CGPoint(x: leftPadding, y: normYBottom))
                    path.addLine(to: CGPoint(x: leftPadding + plotW, y: normYBottom))
                }
                .stroke(Color.orange.opacity(0.45),
                        style: StrokeStyle(lineWidth: 1, dash: [5, 4]))

                // Линия верхнего порога
                Path { path in
                    path.move(to:    CGPoint(x: leftPadding, y: normYTop))
                    path.addLine(to: CGPoint(x: leftPadding + plotW, y: normYTop))
                }
                .stroke(Color.red.opacity(0.35),
                        style: StrokeStyle(lineWidth: 1, dash: [5, 4]))

                // Линии сетки + шкала Y
                ForEach(ySteps, id: \.self) { step in
                    let yPos = topPadding + plotH * CGFloat(1 - step / yMax)

                    Path { path in
                        path.move(to:    CGPoint(x: leftPadding, y: yPos))
                        path.addLine(to: CGPoint(x: leftPadding + plotW, y: yPos))
                    }
                    .stroke(
                        step == 0
                            ? Color(red: 0.55, green: 0.53, blue: 0.95).opacity(0.30)
                            : Color.gray.opacity(0.12),
                        style: StrokeStyle(
                            lineWidth: step == 0 ? 1.5 : 1,
                            dash:      step == 0 ? [] : [4, 4]
                        )
                    )

                    Text(formatValue(step))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: leftPadding - 6, alignment: .trailing)
                        .position(x: (leftPadding - 6) / 2, y: yPos)
                }

                // Столбики
                ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                    let xCenter = leftPadding
                        + barWidth / 2
                        + CGFloat(index) * (barWidth + spacing)

                    let barH    = max(4, plotH * CGFloat(entry.value / yMax))
                    let yBottom = topPadding + plotH
                    let yTop    = yBottom - barH
                    let isSelected = selectedIndex == index

                    // Столбик
                    RoundedRectangle(cornerRadius: min(6, barWidth / 2))
                        .fill(
                            LinearGradient(
                                colors: [
                                    barColor(for: entry.value).opacity(isSelected ? 1.0 : 0.75),
                                    barColor(for: entry.value)
                                ],
                                startPoint: .top,
                                endPoint:   .bottom
                            )
                        )
                        .frame(width: barWidth, height: barH)
                        .scaleEffect(isSelected ? 1.05 : 1.0, anchor: .bottom)
                        .position(x: xCenter, y: yTop + barH / 2)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedIndex = (selectedIndex == index) ? nil : index
                            }
                        }

                    // Значение над столбиком
                    if barWidth >= 20 && !isSelected {
                        Text(formatValue(entry.value))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(barColor(for: entry.value))
                            .position(x: xCenter, y: yTop - 10)
                    }

                    // Метка по X
                    if index % labelStep == 0 {
                        Text(xLabel(from: entry.date))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(isSelected ? barColor(for: entry.value) : .gray)
                            .position(x: xCenter,
                                      y: topPadding + plotH + bottomPadding / 2)
                    }
                }

                // Tap на пустое место — снимаем выделение
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { withAnimation { selectedIndex = nil } }
                    .zIndex(-1)
            }
           
            .clipped()
          
            .overlay(alignment: .topLeading) {
                if let t = tooltipInfo {
                    let tooltipW: CGFloat = 130
                    let tooltipH: CGFloat = 44
                    let clampedX = min(
                        max(t.xCenter, t.leftPadding + tooltipW / 2),
                        t.leftPadding + t.plotW - tooltipW / 2
                    )
                    let clampedY = max(
                        t.yTop - tooltipH / 2 - 12,
                        t.topPadding + tooltipH / 2
                    )

                    VStack(spacing: 2) {
                        Text(tooltipDate(from: t.date))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                        Text("\(formatValue(t.value)) \(glucoseUnit)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(width: tooltipW, height: tooltipH)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(barColor(for: t.value))
                            .shadow(color: barColor(for: t.value).opacity(0.35),
                                    radius: 6, x: 0, y: 3)
                    )
                    .position(x: clampedX, y: clampedY)
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
                    .animation(.easeInOut(duration: 0.15), value: selectedIndex)
                    .zIndex(10)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StatisticsView()
}
