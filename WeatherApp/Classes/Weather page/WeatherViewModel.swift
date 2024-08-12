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

    private let weatherServiceType: WeatherServiceType
    private let coordinator: MainCoordinator
    private let cityModel: CityModel
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization

    init(
        weatherServiceType: WeatherServiceType = WeatherService(),
        coordinator: MainCoordinator,
        cityModel: CityModel
    ) {
        self.weatherServiceType = weatherServiceType
        self.coordinator = coordinator
        self.cityModel = cityModel
    }
}

extension WeatherViewModel: ViewModelType {

    enum Input {
        case viewDidAppear
    }

    enum Output {
        case fetchWeatherDidSucceed(weather: WeatherModel)
        case handleCity(city: CityModel)
    }

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidAppear:
                self?.handleWeather()
                self?.handleCity()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    private func handleWeather() {
        weatherServiceType.getWeather(for: cityModel.cityKey).sink { completion in
            if case .failure(let error) = completion {
                print(error)
            }
        } receiveValue: { [weak self] weather in
            self?.output.send(.fetchWeatherDidSucceed(weather: weather))
        }.store(in: &cancellables)
    }
    
    private func handleCity() {
        output.send(.handleCity(city: cityModel)) 
    }
}
