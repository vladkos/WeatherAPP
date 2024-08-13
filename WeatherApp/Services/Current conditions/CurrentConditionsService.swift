//
//  CurrentConditionsService.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 12/08/2024.
//

import Foundation
import Combine

final class CurrentConditionsService: CurrentConditionsType {
    func getCurrentWeather(for cityKey: String) -> AnyPublisher<[CurrentConditionsModel], any Error> {
        let baseUrl = "http://dataservice.accuweather.com/currentconditions/v1/\(cityKey)"
        let queryItems = [
            URLQueryItem(name: "apikey", value: "muSApLyJoXuvUvLTEDSPmaCbYCawJndA"),
            URLQueryItem(name: "details", value: "false")
        ]
        var urlComps = URLComponents(string: baseUrl)!
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
