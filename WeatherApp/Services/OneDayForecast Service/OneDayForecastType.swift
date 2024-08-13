//
//  OneDayForecastServiceType.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 10/08/2024.
//

import Foundation
import Combine

protocol OneDayForecastType {
    func getWeather(for cityKey: String, metric: Bool) -> AnyPublisher<WeatherModel, Error>
}
