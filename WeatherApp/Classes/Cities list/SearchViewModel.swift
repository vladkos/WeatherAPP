//
//  SearchViewModel.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 07/08/2024.
//

import Foundation
import Combine

final class SearchViewModel: ViewModelType {
    
    enum Input {
        case didSearchCity(_ text: String)
        case didSelectCity(_ city: CityModel)
    }
    
    enum Output {
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
            case .didSearchCity(let text):
                self?.handleGetCities(by: text)
            case .didSelectCity(let city):
                self?.coordinator.toDetails(city)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    private func handleGetCities(by q: String) {
        citiesServiceType.getCities(q).sink { [weak self] completion in
            if case .failure = completion {
                self?.output.send(.fetchCitiesDidSucceed(cities: []))
            }
        } receiveValue: { [weak self] cities in
            self?.output.send(.fetchCitiesDidSucceed(cities: cities))
        }.store(in: &cancellables)
    }
}
