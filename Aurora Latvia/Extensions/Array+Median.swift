//
//  Array+Median.swift
//  Aurora Latvia
//

import Foundation

extension Collection where Element: BinaryFloatingPoint {
    /// Middle value of the sorted collection, or the average of the two middle values
    /// when the count is even. Returns `nil` for an empty collection.
    var median: Element? {
        guard !isEmpty else { return nil }
        let sorted = self.sorted()
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[middle - 1] + sorted[middle]) / 2
        }
        return sorted[middle]
    }
}

extension Collection where Element: BinaryInteger {
    /// Median as `Double`, since the average of two middle integers can be fractional.
    /// Returns `nil` for an empty collection.
    var median: Double? {
        map(Double.init).median
    }
}
