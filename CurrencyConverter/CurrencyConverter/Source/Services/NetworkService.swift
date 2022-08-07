//
//  NetworkService.swift
//  CurrencyConverter
//
//  Created by Pavlo Deinega on 05.08.2022.
//

import Foundation

class NetworkService {
    private let baseURL = "https://bank.gov.ua/NBUStatService/v1/statdirectory"
    private let session = URLSession(configuration: .default)
    private var tasks = [String: URLSessionDataTask]()

    func requestCurrencies(for date: String, completion: @escaping (Result<[Currency], Error>) -> Void) {
        func completionOnMainThread(completion: @escaping () -> Void) {
            DispatchQueue.main.async { completion() }
        }
        
        var components = URLComponents(string: baseURL + "/exchange")
        components?.queryItems = [URLQueryItem(name: "date", value: date), URLQueryItem(name: "json", value: "")]
        guard let url = components?.url else {
            completionOnMainThread { completion(.failure(NetworkError.couldNotComposeURL)) }
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completionOnMainThread { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                completionOnMainThread { completion(.failure(NetworkError.emptyData)) }
                return
            }

            do {
                let decodedData = try JSONDecoder().decode([Currency].self, from: data)
                completionOnMainThread { completion(.success(decodedData)) }
            } catch {
                completionOnMainThread { completion(.failure(error)) }
            }
        }
        task.resume()
        if let absoluteString = task.originalRequest?.url?.absoluteString {
            tasks[absoluteString]?.cancel()
            tasks[absoluteString] = task
        }
    }
    
    func cancelAllTasks() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }
}
