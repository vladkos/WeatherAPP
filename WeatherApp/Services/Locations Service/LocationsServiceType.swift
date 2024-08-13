//
//  LocationsServiceType.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 09/08/2024.
//

import Foundation
import Combine

protocol LocationsServiceType {
    func getLocations(_ q: String) -> AnyPublisher<[LocationModel], Error>
}
