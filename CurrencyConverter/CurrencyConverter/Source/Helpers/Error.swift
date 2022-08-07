//
//  Error.swift
//  CurrencyConverter
//
//  Created by Pavlo Deinega on 05.08.2022.
//

import Foundation

enum NetworkError: LocalizedError {
    case couldNotComposeURL
    case emptyData
    case noOccurencesPresent
    
    var errorDescription: String? {
        switch self {
        case .couldNotComposeURL: return "The URL could not be composed."
        case .emptyData: return "Server returned empty data."
        case .noOccurencesPresent: return "No data present for specified date. Try choosing another one."
        }
    }
}
