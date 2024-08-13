//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 09/08/2024.
//

import UIKit
import Combine

final class WeatherViewModel {

    // MARK: - Properties

    private let oneDayForecastType: OneDayForecastType
    private let twelveHoursForecastType: TwelveHoursForecastType
    private let currentConditionsType: CurrentConditionsType
    private let coordinator: MainCoordinator
    private let locationModel: LocationModel
    private let output: PassthroughSubject<Output, Never> = .init()
    private let setUserDefaults: (Any, String) -> ()
    private let getBoolValueFromUserDefaults: (String) -> (Bool)
    private var cancellables = Set<AnyCancellable>()
    private let isMetricUserDefaultsKey = "isMetric"
    
    private var currentConditions: CurrentConditionsModel?
    
    // MARK: - Initialization

    init(
        oneDayForecastType: OneDayForecastType = OneDayForecastService(),
        twelveHoursForecastType: TwelveHoursForecastType = TwelveHoursForecastService(),
        currentConditionsType: CurrentConditionsType = CurrentConditionsService(),
        coordinator: MainCoordinator,
        locationModel: LocationModel,
        setUserDefaults: @escaping (Any, String) -> () = UserDefaults.standard.set,
        getBoolValueFromUserDefaults: @escaping (String) -> (Bool) = UserDefaults.standard.bool
    ) {
        self.oneDayForecastType = oneDayForecastType
        self.twelveHoursForecastType = twelveHoursForecastType
        self.currentConditionsType = currentConditionsType
        self.coordinator = coordinator
        self.locationModel = locationModel
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
        case outputCurrentTemperature(_ currentTemperature: String, color: UIColor)
        case handleLocation(location: LocationModel)
        case outputMetric(_ metric: Bool)
        case outputTwelveHoursForecast(_ weather: [TwelveHoursForecastModel])
    }

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidAppear:
                self?.handleOneDayForecast()
                self?.handleTwelveHoursForecast()
                self?.handleCurrentConditions()
                self?.handleLocation()
                self?.output.send(.outputMetric(self?.currentMetric() ?? false))
            case .metricDidChange(let metric):
                self?.setIsMetric(metric)
                self?.outputCurrentTemperature()
                self?.handleOneDayForecast()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    private func handleOneDayForecast() {
        oneDayForecastType.getWeather(for: locationModel.cityKey, metric: currentMetric()).sink { completion in
            if case .failure(let error) = completion {
                print(error)
            }
        } receiveValue: { [weak self] weather in
            guard let self else { return }
            let metric: CurrentConditionsModel.Temperature.Details.UnitType = self.currentMetric() ? .celsius : .fahrenheit
            let minMax = "\(weather.minTemperature)\(metric.value) - \( weather.maxTemperature)\(metric.value)"
            self.output.send(.outputMinMaxTemperature(minMax))
        }.store(in: &cancellables)
    }
    
    private func handleTwelveHoursForecast() {
        twelveHoursForecastType.getWeather(for: locationModel.cityKey, metric: currentMetric()).sink { completion in
            if case .failure(let error) = completion {
                print(error)
            }
        } receiveValue: { [weak self] weather in
            guard let self else { return }
            self.output.send(.outputTwelveHoursForecast(weather))
        }.store(in: &cancellables)
    }
    
    private func handleCurrentConditions() {
        currentConditionsType.getCurrentWeather(for: locationModel.cityKey).sink { completion in
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
        let color: UIColor
        switch currentConditions.currentTemperatureValue(metric: currentMetric()) {
        case let x where x < 10:
            color = .blue
        case let x where x >= 10 && x <= 20:
            color = .black
        default:
            color = .red
        }
        output.send(.outputCurrentTemperature(
            currentConditions.currentTemperature(metric: currentMetric()),
            color: color
        ))
    }
    
    private func handleLocation() {
        output.send(.handleLocation(location: locationModel)) 
    }
    
    private func setIsMetric(_ value: Bool) {
        setUserDefaults(value, isMetricUserDefaultsKey)
    }
}
