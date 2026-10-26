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
    
    private func getKpValueColor(from kp: Float?) -> Color {
        guard let kp else {
            return .mainValueGray
        }
        
        if kp >= 5 {
            return .mainValueGreen
        }
        
        if kp >= 4 && kp < 5 {
            return .mainValueOrange
        }
        
        return .mainValueGray
    }
    
    private var kpValueFormatted: String {
        guard let kpValue = kpIndex?.kp else {
            return "-"
        }
        return "\(kpValue.formatted(.number.precision(.fractionLength(0...2))))"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 10) {
                Image(systemName: "rays")
                    .foregroundStyle(Color.kpIndex)
                    .frame(width: 30, height: 30)
                    .background(.kpIndexBackground)
                    .cornerRadius(12)
                
                VStack(alignment: .leading) {
                    Text("Geomagnetic activity")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.cardText)
                    
                    Text("Threshold: 5")
                        .font(.system(size: 12))
                        .foregroundStyle(.cardTextSecondary)
                }
                
                Spacer()
                
                Text("Kp \(kpValueFormatted)")
                    .font(.system(size: 18, weight: .bold))
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
                            xStart: .value("Start", kpItem.date),
                            xEnd: .value("End", kpItem.date.addingTimeInterval(3 * 3600 - 1200)),
                            yStart: .value("Base", 0.0),
                            yEnd: .value("Kp Index", kpItem.kp)
                        )
                        .foregroundStyle(getKpValueColor(from: kpItem.kp).gradient)
                        .cornerRadius(3)
                    }
                }
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.hour())
                            .foregroundStyle(.cardTextSecondary)
                    }
                }
            }
        }
        .padding()
        .background(.cardBackground)
        .cornerRadius(26)
        .padding()
    }
}
