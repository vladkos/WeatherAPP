//
//  CurrentConditionsType.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 12/08/2024.
//

import Foundation
import Combine

protocol CurrentConditionsType {
    func getCurrentWeather(for cityKey: String) -> AnyPublisher<[CurrentConditionsModel], Error>
}
