//
//  SearchViewModel.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 07/08/2024.
//

import Foundation
import Combine

class SearchViewModel {
    
    enum Input {
        case viewDidAppear
        case didSelectCity(_ city: CityModel)
    }
    
    enum Output {
        case fetchCitiesDidFail(error: Error)
        case fetchCitiesDidSucceed(cities: [CityModel])
    }
    
    private let coordinator: MainCoordinator
    private let citiesServiceType: CitiesServiceType
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        citiesServiceType: CitiesServiceType = CitiesService(),
        coordinator: MainCoordinator
    ) {
        self.citiesServiceType = citiesServiceType
        self.coordinator = coordinator
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidAppear:
                self?.handleGetCities()
            case .didSelectCity(let city):
                self?.coordinator.toDetails(city)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    private func handleGetCities(_ q: String = "warsaw") {
        citiesServiceType.getCities(q).sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.output.send(.fetchCitiesDidFail(error: error))
            }
        } receiveValue: { [weak self] cities in
            self?.output.send(.fetchCitiesDidSucceed(cities: cities))
        }.store(in: &cancellables)
    }
}
protocol CitiesServiceType {
    func getCities(_ q: String) -> AnyPublisher<[CityModel], Error>
}

class CitiesService: CitiesServiceType {
    
    func getCities(_ q: String) -> AnyPublisher<[CityModel], Error> {
        let baseUrl = "http://dataservice.accuweather.com/locations/v1/cities/autocomplete"
        let queryItems = [
            URLQueryItem(name: "apikey", value: "muSApLyJoXuvUvLTEDSPmaCbYCawJndA"),
            URLQueryItem(name: "q", value: q)
        ]
        var urlComps = URLComponents(string: baseUrl)!
        urlComps.queryItems = queryItems
        let request = URLRequest(url: urlComps.url!)
        return URLSession.shared.dataTaskPublisher(for: request)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }.map({ $0.data })
            .decode(type: [CityModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
