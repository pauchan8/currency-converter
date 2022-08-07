//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Pavlo Deinega on 05.08.2022.
//

import Foundation

struct Currency: Decodable {
    let id: Int
    let name: String
    let rate: Double
    let code: String
    let date: Date
    
    private enum CodingKeys: String, CodingKey {
        case rate
        case id = "r030"
        case name = "txt"
        case code = "cc"
        case date = "exchangedate"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        rate = try container.decode(Double.self, forKey: .rate)
        code = try container.decode(String.self, forKey: .code)
        let stringDate = try container.decode(String.self, forKey: .date)
        if let date = DateFormatter.defaultFormatter.date(from: stringDate) {
            self.date = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
    }
    
    private init( id: Int, name: String, rate: Double, code: String, date: Date) {
        self.id = id
        self.name = name
        self.rate = rate
        self.code = code
        self.date = date
    }
}

extension Currency {
    static func uah(date: Date = Date()) -> Currency {
        Currency(id: -1, name: "Гривня", rate: 1.0, code: "UAH", date: date)
    }
}
