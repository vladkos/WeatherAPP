//
//  WeatherViewModelTests.swift
//  WeatherAppTests
//
//  Created by Vlad Kostenko on 14/08/2024.
//

import XCTest
import Combine
@testable import WeatherApp

final class WeatherViewModelTests: XCTestCase {
    
    private var sut: WeatherViewModel!
    private var oneDayForecastType: OneDayForecastServiceMock!
    private var twelveHoursForecastType: TwelveHoursForecastMock!
    private var currentConditionsType: CurrentConditionsMock!
    private var coordinatorMock: CoordinatorMock!
    private var locationModel: LocationModel!
    private let vcOutput = PassthroughSubject<WeatherViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var isMetricUserDefaultsKey: String!
    
    override func setUp() {
        oneDayForecastType = OneDayForecastServiceMock()
        twelveHoursForecastType = TwelveHoursForecastMock()
        currentConditionsType = CurrentConditionsMock()
        coordinatorMock = CoordinatorMock(navigationController: UINavigationController())
        locationModel = LocationModel(localizedName: "Warsaw", cityKey: "key", country: .init(localizedName: "Poland"))
        isMetricUserDefaultsKey = "test_isMetric"
        sut = .init(
            oneDayForecastType: oneDayForecastType,
            twelveHoursForecastType: twelveHoursForecastType,
            currentConditionsType: currentConditionsType,
            coordinator: coordinatorMock,
            locationModel: locationModel,
            isMetricUserDefaultsKey: isMetricUserDefaultsKey
        )
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        oneDayForecastType = nil
        sut = nil
    }
    
    func test_oneDayForecast_isCalled() {
        let vmOutput = sut.transform(input: vcOutput.eraseToAnyPublisher())
        
        vmOutput.sink { event in }.store(in: &cancellables)
        vcOutput.send(.viewDidAppear)
        
        XCTAssertEqual(oneDayForecastType.weatherCallCounter, 1)
    }
    
    func test_twelveHoursForecast_isCalled() {
        let vmOutput = sut.transform(input: vcOutput.eraseToAnyPublisher())
        
        vmOutput.sink { event in }.store(in: &cancellables)
        vcOutput.send(.viewDidAppear)
        
        XCTAssertEqual(twelveHoursForecastType.weatherCallCounter, 1)
    }
    
    func test_didHandleLocation_getsLocationToUpdatesView() {
        let vmOutput = sut.transform(input: vcOutput.eraseToAnyPublisher())
        let randomBool = Bool.random()
        let metric: CurrentConditionsModel.Temperature.Details.UnitType = randomBool ? .celsius : .fahrenheit
        UserDefaults.standard.set(randomBool, forKey: isMetricUserDefaultsKey)
        oneDayForecastType.weather = .init(dailyForecasts: [.init(temperature: .init(minimum: .init(value: 12), maximum: .init(value: 21)))])
        twelveHoursForecastType.weather = [.init(temperature: .init(value: 12, unit: "C"), epochDateTime: 123456789)]
        currentConditionsType.weather = [.init(
            weatherText: "description",
            temperature: .init(
                metric: .init(
                    value: 9,
                    unit: .celsius
                ),
                imperial: .init(
                    value: 21,
                    unit: .fahrenheit
                )
            )
        )]
        
        vmOutput.sink { [unowned self] event in
            switch event {
            case .handleLocation(let location):
                XCTAssertEqual(self.locationModel.cityKey, location.cityKey)
                XCTAssertEqual(self.locationModel.localizedName, location.localizedName)
            case .outputMinMaxTemperature(let minMax):
                let weather = self.oneDayForecastType.weather!
                let expectedMinMax = "\(weather.minTemperature)\(metric.value) - \(weather.maxTemperature)\(metric.value)"
                XCTAssertEqual(expectedMinMax, minMax)
            case .outputWeatherDescription(let description):
                XCTAssertEqual(self.currentConditionsType.weather?.first?.weatherText, description)
            case .outputCurrentTemperature(let currentTemperature, let color):
                randomBool ? XCTAssertEqual(currentTemperature, "9℃") : XCTAssertEqual(currentTemperature, "21℉")
                randomBool ? XCTAssertEqual(color, .blue) : XCTAssertEqual(color, .red)
            case .outputMetric(let metric):
                XCTAssertEqual(metric, randomBool)
            case .outputTwelveHoursForecast(let weather):
                XCTAssertEqual(weather.first?.epochDateTime, twelveHoursForecastType.weather?.first?.epochDateTime)
                XCTAssertEqual(weather.first?.hourValue, twelveHoursForecastType.weather?.first?.hourValue)
            }
        }.store(in: &cancellables)
        
        vcOutput.send(.viewDidAppear)
    }
    
    final class OneDayForecastServiceMock: OneDayForecastType {
        var weatherCallCounter = 0
        var weather: WeatherModel?
        
        func getWeather(for cityKey: String, metric: Bool) -> AnyPublisher<WeatherModel, Error> {
            weatherCallCounter += 1
            
            guard let weather else {
                return Fail(error: CustomError())
                    .eraseToAnyPublisher()
            }
            return Just(weather)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    final class TwelveHoursForecastMock: TwelveHoursForecastType {
        var weatherCallCounter = 0
        var weather: [TwelveHoursForecastModel]?
        
        func getWeather(for cityKey: String, metric: Bool) -> AnyPublisher<[TwelveHoursForecastModel], Error> {
            weatherCallCounter += 1
            
            guard let weather else {
                return Fail(error: CustomError())
                    .eraseToAnyPublisher()
            }
            return Just(weather)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    final class CurrentConditionsMock: CurrentConditionsType {
        var weatherCallCounter = 0
        var weather: [CurrentConditionsModel]?
        
        func getCurrentWeather(for cityKey: String) -> AnyPublisher<[CurrentConditionsModel], any Error> {
            weatherCallCounter += 1
            
            guard let weather else {
                return Fail(error: CustomError())
                    .eraseToAnyPublisher()
            }
            return Just(weather)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    final class CoordinatorMock: Coordinator {
        var navigationController: UINavigationController
        
        init(navigationController: UINavigationController) {
            self.navigationController = navigationController
        }
        
        func start() {}
    }
    
    struct CustomError: Error {}
}
