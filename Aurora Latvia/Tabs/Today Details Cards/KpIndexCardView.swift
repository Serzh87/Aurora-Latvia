//
//  KpIndexCardView.swift
//  Aurora Latvia
//
//  Created by Sergey Klus on 26/10/2026.
//

import SwiftUI
import Charts

struct KpIndexCardView: View {
    var kpIndex: KpItem?
    var tonightKpIndexes: [KpItem]
    
    private func getKpValueColor(from kp: Double?) -> Color {
        guard let kp else {
            return .cardText
        }
        
        if kp >= 5 {
            return .mainGreen
        }
        
        if kp >= 4 && kp < 5 {
            return .mainOrange
        }
        
        return .cardText
    }
    
    private func getKpCahrtValueColor(from kp: Double?) -> Color {
        guard let kp else {
            return .barChartGray
        }
        
        if kp >= 5 {
            return .mainGreen
        }
        
        if kp >= 4 && kp < 5 {
            return .mainOrange
        }
        
        return .barChartGray
    }
    
    private var kpValueFormatted: String {
        guard let kpValue = kpIndex?.kp else {
            return "-"
        }
        return kpValue.formatted(.number.precision(.fractionLength(0...2)))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 10) {
                Image(systemName: "rays")
                    .foregroundStyle(.mainGreen)
                    .frame(width: 30, height: 30)
                    .background(.secondaryGreen)
                    .cornerRadius(12)
                
                VStack(alignment: .leading) {
                    Text("Geomagnetic activity")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.cardText)
                    
                    Text("Threshold: 5")
                        .font(.system(size: 12))
                        .foregroundStyle(.cardTextSecondary)
                }
                
                Spacer()
                
                Text("Kp \(kpValueFormatted)")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(getKpValueColor(from: kpIndex?.kp))
            }
            
            if !tonightKpIndexes.isEmpty {
                Chart {
                    RuleMark(y: .value("Threshold", 5))
                        .foregroundStyle(.cardTextSecondary)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                        .accessibilityHidden(true)
                    
                    ForEach(tonightKpIndexes) { kpItem in
                        // NOAA Kp values cover 3-hour windows, so each bar spans its full window
                        // (minus a small gap of 20 minutes) and rises from 0 up to the Kp value.
                        RectangleMark(
                            xStart: .value("Start", kpItem.timeTag),
                            xEnd: .value("End", kpItem.timeTag.addingTimeInterval(3 * 3600 - 1200)),
                            yStart: .value("Base", 0.0),
                            yEnd: .value("Kp Index", kpItem.kp)
                        )
                        .foregroundStyle(getKpCahrtValueColor(from: kpItem.kp))
                        .cornerRadius(4)
                    }
                }
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.hour(), anchor: .top)
                            .foregroundStyle(.cardTextSecondary)
                    }
                }
                .chartYAxis {
                    // Explicit marks with a standard anchor; the auto-generated y-axis labels
                    // otherwise trigger the "Custom UnitPoint values are not supported" warning.
                    AxisMarks(position: .trailing) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(anchor: .leading)
                    }
                }
            }
        }
        .padding()
        .background(.cardBackground, in: .rect(corners: .concentric(minimum: .fixed(24))))
    }
}
