//
//  HistoryPresenter.swift
//  CurrencyConverter
//
//  Created by Pavlo Deinega on 05.08.2022.
//

import Foundation

class HistoryPresenter {
    private let historyService: HistoryService
    
    init(historyService: HistoryService = HistoryService()) {
        self.historyService = historyService
    }
    
    var entries: [String] {
        historyService.latestEntries()
    }
    
    func deleteAll() {
        historyService.deleteAll()
    }
}
