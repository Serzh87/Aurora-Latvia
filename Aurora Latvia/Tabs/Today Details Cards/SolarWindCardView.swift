//
//  SolarWindCardView.swift
//  Aurora Latvia
//
//  Created by Sergey Klus on 30/10/2026.
//

import SwiftUI

struct SolarWindCardView: View {
    var currentWindMagnitude: CurrentRTSWWindMagnitude?
    var currentWindSpeed: CurrentRTSWWindSpped?
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "wind")
                    .foregroundStyle(.mainOrange)
                    .frame(width: 30, height: 30)
                    .background(.secondaryOrange, in: .rect(cornerRadius: 12))
                
                Text("Solar Wind now")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.cardText)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                SolarWindInfoView(
                    title: "Bz",
                    value: currentWindMagnitude?.bz,
                    valueType: "nT",
                    windTone: currentWindMagnitude?.windTone ?? .quiet,
                    info: currentWindMagnitude?.info ?? ""
                )
                
                SolarWindInfoView(
                    title: "Speed",
                    value: currentWindSpeed?.speed,
                    valueType: "km/s",
                    windTone: currentWindSpeed?.windTone ?? .quiet,
                    info: currentWindSpeed?.info ?? ""
                )
            }
            .fixedSize(horizontal: false, vertical: true)
            
            if let density = currentWindSpeed?.density, density >= 15 {
                SolarWindDensityView(density: density)
            }
        }
        .padding()
        .background(.cardBackground, in: .rect(corners: .concentric(minimum: .fixed(24))))
    }
}
