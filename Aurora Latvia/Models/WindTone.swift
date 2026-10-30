//
//  WindTone.swift
//  Aurora Latvia
//
//  Created by Sergey Klus on 30/10/2026.
//

import SwiftUI

enum WindTone { case quiet, watch, good, strong }

extension WindTone {
    var backgroundColor: Color {
        switch self {
        case .quiet:
            .secondaryGray
        case .watch:
            .secondaryOrange
        case .good, .strong:
            .secondaryGreen
        }
    }
    
    var valueColor: Color {
        switch self {
        case .quiet:
            .mainGray
        case .watch:
            .mainOrange
        case .good, .strong:
            .mainGreen
        }
    }
    
    var textColor: Color {
        switch self {
        case .quiet:
            .mainGrayLight
        case .watch:
            .mainOrangeLight
        case .good, .strong:
            .mainGreenLight
        }
    }
}
