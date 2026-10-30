//
//  SolarWindInfoView.swift
//  Aurora Latvia
//
//  Created by Sergey Klus on 30/10/2026.
//

import SwiftUI

struct SolarWindInfoView: View {
    let title: String
    let value: Double?
    let valueType: String
    let windTone: WindTone
    let info: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 12))
            
            if let value {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value.formatted(.number.precision(.fractionLength(0...1)))).font(.system(size: 28, weight: .bold))
                        .foregroundStyle(windTone.valueColor)
                    Text(valueType).font(.system(size: 14, weight: .semibold))
                }
                
                Text(info)
                    .font(.system(size: 12))
            } else {
                Text("-").font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.mainGray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(windTone.backgroundColor, in: .rect(corners: .concentric(minimum: .fixed(12))))
        .foregroundStyle(windTone.textColor)
    }
}
