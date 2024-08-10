//
//  ViewModelType.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 09/08/2024.
//

import Foundation
import Combine

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}
