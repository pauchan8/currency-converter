//
//  HistoryService.swift
//  CurrencyConverter
//
//  Created by Pavlo Deinega on 06.08.2022.
//

import Foundation

class HistoryService {
    private struct Constants {
        static let suiteName = "history"
        static let entriesKey = "entries"
    }
    
    private let defaults = UserDefaults(suiteName: Constants.suiteName)!
    
    func addEntry(_ entry: String) {
        var entries = latestEntries()
        entries.insert(entry, at: 0)
        if entries.count > 10 {
            entries.removeLast()
        }
        saveEntries(entries)
    }
    
    func deleteAll() {
        defaults.setValue(nil, forKey: Constants.entriesKey)
    }
    
    func latestEntries() -> [String] {
        defaults.value(forKey: Constants.entriesKey) as? [String] ?? []
    }
    
    private func saveEntries(_ entries: [String]) {
        defaults.setValue(entries, forKey: Constants.entriesKey)
    }
}
