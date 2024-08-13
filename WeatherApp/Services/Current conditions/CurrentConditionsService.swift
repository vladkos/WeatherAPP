//
//  CurrentConditionsService.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 12/08/2024.
//

import Foundation
import Combine

final class CurrentConditionsService: CurrentConditionsType {
    private let apiKey: String
    private let baseUrl: String
    
    init(
        apiKey: String = Constants.apiKey,
        baseUrl: String = Constants.baseUrl
    ) {
        self.apiKey = apiKey
        self.baseUrl = baseUrl
    }
    
    func getCurrentWeather(for cityKey: String) -> AnyPublisher<[CurrentConditionsModel], any Error> {
        let url = "\(baseUrl)/currentconditions/v1/\(cityKey)"
        let queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "details", value: "false")
        ]
        var urlComps = URLComponents(string: url)!
        urlComps.queryItems = queryItems
        
        let request = URLRequest(url: urlComps.url!)
        return URLSession.shared.dataTaskPublisher(for: request)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }.map({ $0.data })
            .decode(type: [CurrentConditionsModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
