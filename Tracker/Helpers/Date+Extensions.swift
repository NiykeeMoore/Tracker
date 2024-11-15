//
//  Date+Extensions.swift
//  Tracker
//
//  Created by Niykee Moore on 14.11.2024.
//

import Foundation

extension Date {
    var onlyDate: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)!
    }
}
