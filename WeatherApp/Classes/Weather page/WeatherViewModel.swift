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
    private let currentConditionsType: CurrentConditionsType
    private let coordinator: MainCoordinator
    private let cityModel: CityModel
    private let output: PassthroughSubject<Output, Never> = .init()
    private let setUserDefaults: (Any, String) -> ()
    private let getBoolValueFromUserDefaults: (String) -> (Bool)
    private var cancellables = Set<AnyCancellable>()
    private let isMetricUserDefaultsKey = "isMetric"
    
    private var currentConditions: CurrentConditionsModel?
    
    // MARK: - Initialization

    init(
        weatherServiceType: WeatherServiceType = WeatherService(),
        currentConditionsType: CurrentConditionsType = CurrentConditionsService(),
        coordinator: MainCoordinator,
        cityModel: CityModel,
        setUserDefaults: @escaping (Any, String) -> () = UserDefaults.standard.set,
        getBoolValueFromUserDefaults: @escaping (String) -> (Bool) = UserDefaults.standard.bool
    ) {
        self.weatherServiceType = weatherServiceType
        self.currentConditionsType = currentConditionsType
        self.coordinator = coordinator
        self.cityModel = cityModel
        self.setUserDefaults = setUserDefaults
        self.getBoolValueFromUserDefaults = getBoolValueFromUserDefaults
    }
}

extension WeatherViewModel: ViewModelType {

    enum Input {
        case viewDidAppear
        case metricDidChange(value: Bool)
    }

    enum Output {
        case outputMinMaxTemperature(_ minMax: String)
        case outputWeatherDescription(_ description: String)
        case outputCurrentTemperature(_ currentTemperature: String)
        case handleCity(city: CityModel)
        case outputMetric(_ metric: Bool)
    }

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidAppear:
                self?.handleForecast()
                self?.handleCurrentConditions()
                self?.handleCity()
                self?.output.send(.outputMetric(self?.currentMetric() ?? false))
            case .metricDidChange(let metric):
                self?.setIsMetric(metric)
                self?.outputCurrentTemperature()
                self?.handleForecast()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    private func handleForecast() {
        weatherServiceType.getWeather(for: cityModel.cityKey, metric: currentMetric()).sink { completion in
            if case .failure(let error) = completion {
                print(error)
            }
        } receiveValue: { [weak self] weather in
            guard let self else { return }
            let metric: CurrentConditionsModel.Temperature.Details.UnitType = self.currentMetric() ? .celsius : .fahrenheit
            let minMax = "\(weather.minTemperature)\(metric.rawValue) - \( weather.maxTemperature)\(metric.rawValue)"
            self.output.send(.outputMinMaxTemperature(minMax))
        }.store(in: &cancellables)
    }
    
    private func handleCurrentConditions() {
        currentConditionsType.getCurrentWeather(for: cityModel.cityKey).sink { completion in
            if case .failure(let error) = completion {
                print(error)
            }
        } receiveValue: { [weak self] currentConditions in
            self?.currentConditions = currentConditions.first
            self?.outputCurrentTemperature()
            self?.output.send(.outputWeatherDescription(currentConditions.first?.weatherText ?? ""))
        }.store(in: &cancellables)
    }
    
    private func currentMetric() -> (Bool) {
        getBoolValueFromUserDefaults(isMetricUserDefaultsKey)
    }
    
    private func outputCurrentTemperature() {
        guard let currentConditions else { return }
        output.send(.outputCurrentTemperature(currentConditions.currentTemperature(metric: currentMetric())))
    }
    
    private func handleCity() {
        output.send(.handleCity(city: cityModel)) 
    }
    
    private func setIsMetric(_ value: Bool) {
        setUserDefaults(value, isMetricUserDefaultsKey)
    }
}
