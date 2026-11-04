//
//  CloudCoverView.swift
//  Aurora Latvia
//
//  Created by Sergey Klus on 04/11/2026.
//

import SwiftUI
import WeatherKit
import Charts

struct CloudCoverView: View {
    var tonightCloudCover: [CloudCover] = []
    var currentWeather: Weather?
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 10) {
                Image(systemName: "cloud")
                    .foregroundStyle(.mainBlue)
                    .frame(width: 30, height: 30)
                    .background(.secondaryBlue, in: .rect(corners: .concentric(minimum: .fixed(10))))
                
                VStack(alignment: .leading) {
                    Text("Cloud cover")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.cardText)
                    
                    Text(currentWeather?.currentWeather.condition.description ?? "-")
                        .font(.system(size: 12))
                        .foregroundStyle(.cardTextSecondary)
                }
                
                Spacer()
                
                if let currentWeather {
                    Text(currentWeather.currentWeather.cloudCover.formatted(.percent))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.cardText)
                } else {
                    Text("-")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.cardText)
                }
            }
            
            if !tonightCloudCover.isEmpty {
                Chart() {
                    ForEach(tonightCloudCover) { cloud in
                        AreaMark(
                            x: .value("Hour", cloud.date),
                            y: .value("Cloud cover", cloud.cover)
                        )
                        .foregroundStyle(Gradient(colors: [.cloudCover.opacity(0.8), .cloudCover.opacity(0.3)]))
                        .interpolationMethod(.monotone)
                        
                        LineMark(
                            x: .value("Hour", cloud.date),
                            y: .value("Cloud cover", cloud.cover)
                        )
                        .foregroundStyle(.cloudCover)
                        .interpolationMethod(.monotone)
                    }
                }
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.hour())
                            .foregroundStyle(.cardTextSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(.cardTextSecondary.opacity(0.3))
                        
                        AxisValueLabel((value.as(Double.self) ?? 0).formatted(.percent))
                            .foregroundStyle(.cardTextSecondary)
                    }
                }
            }
        }
        .padding()
        .background(.cardBackground, in: .rect(corners: .concentric(minimum: .fixed(24))))
    }
}

#Preview {
    CloudCoverView()
}
