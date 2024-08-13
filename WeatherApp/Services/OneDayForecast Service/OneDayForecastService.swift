//
//  OneDayForecastService.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 10/08/2024.
//

import Foundation
import Combine

final class OneDayForecastService: OneDayForecastType {
    
    func getWeather(for cityKey: String, metric: Bool) -> AnyPublisher<WeatherModel, Error> {
        let baseUrl = "http://dataservice.accuweather.com/forecasts/v1/daily/1day/\(cityKey)"
        let queryItems = [
            URLQueryItem(name: "apikey", value: "muSApLyJoXuvUvLTEDSPmaCbYCawJndA"),
            URLQueryItem(name: "details", value: "true"),
            URLQueryItem(name: "metric", value: metric.description)
        ]
        var urlComps = URLComponents(string: baseUrl)!
        urlComps.queryItems = queryItems
        let request = URLRequest(url: urlComps.url!)
        return URLSession.shared.dataTaskPublisher(for: request)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }.map({ $0.data })
            .decode(type: WeatherModel.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
