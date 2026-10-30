//
//  SolarWindDensityView.swift
//  Aurora Latvia
//
//  Created by Sergey Klus on 30/10/2026.
//

import SwiftUI

struct SolarWindDensityView: View {
    let density: Double
    
    var body: some View {
        HStack {
            Image(systemName: "bolt")
                .font(.system(size: 14))
                .foregroundStyle(.bolt)
                .frame(width: 16, height: 16)
            
            Text("Dense flow \(density.formatted(.number.precision(.fractionLength(0)))) p/cm³ - aurora may be brighter")
                .font(.system(size: 14))
                .foregroundStyle(.secondaryCardText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.secondaryCardBackground, in: .rect(corners: .concentric(minimum: .fixed(12))))
    }
}
