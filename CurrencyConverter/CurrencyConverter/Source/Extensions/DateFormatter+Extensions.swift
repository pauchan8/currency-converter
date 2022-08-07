//
//  DateFormatter+Extensions.swift
//  CurrencyConverter
//
//  Created by Pavlo Deinega on 05.08.2022.
//

import Foundation

extension DateFormatter {
    static let defaultFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    static let reverseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
}
