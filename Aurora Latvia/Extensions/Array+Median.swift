//
//  Array+Median.swift
//  Aurora Latvia
//

import Foundation

extension Collection where Element: BinaryFloatingPoint {
    var median: Element? {
        guard !isEmpty else { return nil }
        let sorted = self.sorted()
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[middle - 1] + sorted[middle]) / 2
        }
        return sorted[middle]
    }
    
    var mean: Element? {
        isEmpty ? nil : reduce(0, +) / Element(count)
    }
}
