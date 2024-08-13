//
//  TwelveHoursForecastService.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 13/08/2024.
//

import Foundation
import Combine

final class TwelveHoursForecastService: TwelveHoursForecastType {
    private let apiKey: String
    private let baseUrl: String
    
    init(
        apiKey: String = Constants.apiKey,
        baseUrl: String = Constants.baseUrl
    ) {
        self.apiKey = apiKey
        self.baseUrl = baseUrl
    }
    
    func getWeather(for cityKey: String, metric: Bool) -> AnyPublisher<[TwelveHoursForecastModel], Error> {
        let url = "\(baseUrl)/forecasts/v1/hourly/12hour/\(cityKey)"
        let queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "details", value: "true"),
            URLQueryItem(name: "metric", value: metric.description)
        ]
        var urlComps = URLComponents(string: url)!
        urlComps.queryItems = queryItems
        
        let request = URLRequest(url: urlComps.url!)
        return URLSession.shared.dataTaskPublisher(for: request)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }.map({ 
                $0.data
            })
            .decode(type: [TwelveHoursForecastModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
