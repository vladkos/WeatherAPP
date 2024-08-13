//
//  TwelveHoursForecastServiceType.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 13/08/2024.
//

import Foundation
import Combine

protocol TwelveHoursForecastType {
    func getWeather(for cityKey: String, metric: Bool) -> AnyPublisher<[TwelveHoursForecastModel], Error>
}
