//
//  ConverterPresenter.swift
//  CurrencyConverter
//
//  Created by Pavlo Deinega on 04.08.2022.
//

import Foundation

class ConverterPresenter {
    private let networkService: NetworkService
    private let historyService: HistoryService
    private var map = [String: [Currency]]()
    private var currentDate = ""
    private var currentData: [Currency] { map[currentDate] ?? [] }
    private var initialCurrency: Currency?
    private var resultCurrency: Currency?
    
    private var amountToConvert: Decimal = 1
    private var resultAmount: Decimal = 0
    
    var initalCurrencyString: String {
        initialCurrency?.code ?? ""
    }
    var resultCurrencyString: String {
        resultCurrency?.code ?? ""
    }
    
    var initialCurrencyIndex: Int {
        currentData.firstIndex(where: { $0.code == (initialCurrency?.code ?? "") }) ?? 0
    }
    var resultCurrencyIndex: Int {
        currentData.firstIndex(where: { $0.code == (resultCurrency?.code ?? "") }) ?? 0
    }
    
    var amountToConvertString: String {
        amountToConvert.formattedString ?? ""
    }
    var resultAmountString: String {
        resultAmount.formattedString ?? ""
    }
    
    init(networkService: NetworkService = NetworkService(), historyService: HistoryService = HistoryService()) {
        self.networkService = networkService
        self.historyService = historyService
    }
    
    func loadData(for date: Date, completion: @escaping (Error?) -> Void) {
        let stringDate = DateFormatter.defaultFormatter.string(from: date)
        guard map[stringDate] == nil else {
            completion(nil)
            return
        }
        
        let serverFriendlyDate = DateFormatter.reverseDateFormatter.string(from: date)
        networkService.requestCurrencies(for: serverFriendlyDate) { [weak self] result in
            switch result {
            case .success(let currencies):
                guard !currencies.isEmpty else {
                    completion(NetworkError.noOccurencesPresent)
                    return
                }
                
                let uahCurrency = Currency.uah(date: date)
                self?.map[stringDate] = currencies + [uahCurrency]
                self?.currentDate = stringDate
                self?.performUpdateIfNeeded()
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func availableCurrencies() -> [String] {
        currentData.map { $0.code }
    }
    
    func peformReverse() {
        (initialCurrency, resultCurrency) = (resultCurrency, initialCurrency)
        performUpdateIfNeeded()
    }
    
    func setInitialCurrency(_ code: String) {
        if let currency = currentData.first(where: { $0.code == code }) {
            initialCurrency = currency
            performUpdateIfNeeded()
        }
    }
    
    func setResultCurrency(_ code: String) {
        if let currency = currentData.first(where: { $0.code == code }) {
            resultCurrency = currency
            performUpdateIfNeeded()
        }
    }
    
    func setAmountToConvert(_ setAmountToConvert: Decimal) {
        self.amountToConvert = setAmountToConvert
        performUpdateIfNeeded()
    }

    private func performUpdateIfNeeded() {
        guard let data = map[currentDate] else { return }
        
        if initialCurrency == nil {
            initialCurrency = data.first
        }
        
        if resultCurrency == nil {
            resultCurrency = data.first(where: { $0.isUAH })
        }
        
        guard let initialCurrency = initialCurrency, let resultCurrency = resultCurrency else { return }
        
        if initialCurrency.isUAH {
            resultAmount = amountToConvert / Decimal(resultCurrency.rate)
        } else {
            resultAmount = amountToConvert * Decimal(initialCurrency.rate / resultCurrency.rate)
        }
        saveCurrentEntry()
    }
    
    private func saveCurrentEntry() {
        let text = "\(amountToConvertString) \(initalCurrencyString) equals to \(resultAmountString) \(resultCurrencyString)"
        historyService.addEntry(text)
    }
}

private extension Currency {
    var isUAH: Bool {
        code == "UAH"
    }
}

private extension Decimal {
    var formattedString: String? {
        let formatted = Decimal.formatter.string(for: self)
        if formatted == "0" {
            return "\(self)"
        } else {
            return formatted
        }
    }
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
