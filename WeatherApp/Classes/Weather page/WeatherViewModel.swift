//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 09/08/2024.
//

import Foundation
import Combine

final class WeatherViewModel {

    // MARK: - Properties

    private let coordinator: MainCoordinator
    private let cityModel: CityModel
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization

    init(
        coordinator: MainCoordinator,
        cityModel: CityModel
    ) {
        self.coordinator = coordinator
        self.cityModel = cityModel
    }
}

extension WeatherViewModel: ViewModelType {

    struct Input { }

    struct Output {
    }

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { event in
            
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}
