//
//  CitiesServiceType.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 09/08/2024.
//

import Foundation
import Combine

protocol CitiesServiceType {
    func getCities(_ q: String) -> AnyPublisher<[CityModel], Error>
}
