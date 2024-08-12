//
//  WeatherServiceType.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 10/08/2024.
//

import Foundation
import Combine

protocol WeatherServiceType {
    func getWeather(for cityKey: String) -> AnyPublisher<WeatherModel, Error>
}
