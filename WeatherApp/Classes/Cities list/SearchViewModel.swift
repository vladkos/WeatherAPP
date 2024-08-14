//
//  SearchViewModel.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 07/08/2024.
//

import Foundation
import Combine

protocol SearchViewModelProtocol {
    func title() -> String
}

final class SearchViewModel: ViewModelType, SearchViewModelProtocol {
    
    enum Input {
        case didSearchLocation(_ text: String)
        case didSelectLocation(_ locatoin: LocationModel)
    }
    
    enum Output {
        case fetchLocationsDidSucceed(locations: [LocationModel])
    }
    
    private let coordinator: Coordinator & LocationsCoordinatorProtocol
    private let locationsServiceType: LocationsServiceType
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        locationsServiceType: LocationsServiceType = LocationsService(),
        coordinator: Coordinator & LocationsCoordinatorProtocol
    ) {
        self.locationsServiceType = locationsServiceType
        self.coordinator = coordinator
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .didSearchLocation(let text):
                self?.handleGetLocations(by: text)
            case .didSelectLocation(let location):
                self?.coordinator.toDetails(location)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func title() -> String {
        "Locations"
    }
    
    private func handleGetLocations(by q: String) {
        locationsServiceType.getLocations(q).sink { [weak self] completion in
            if case .failure = completion {
                self?.output.send(.fetchLocationsDidSucceed(locations: []))
            }
        } receiveValue: { [weak self] locations in
            self?.output.send(.fetchLocationsDidSucceed(locations: locations))
        }.store(in: &cancellables)
    }
}
