//
//  LocationsViewModelTests.swift
//  WeatherAppTests
//
//  Created by Vlad Kostenko on 14/08/2024.
//

import XCTest
import Combine
@testable import WeatherApp

final class LocationsViewModelTests: XCTestCase {
    
    private var sut: SearchViewModel!
    private var locationsService: LocationsServiceMock!
    private var coordinatorMock: MainCoordinatorMock!
    private let vcOutput = PassthroughSubject<SearchViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        locationsService = LocationsServiceMock()
        coordinatorMock = MainCoordinatorMock(navigationController: UINavigationController())
        sut = .init(
            locationsServiceType: locationsService,
            coordinator: coordinatorMock
        )
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        locationsService = nil
        sut = nil
    }
    
    func test_didSearchLocation_isCalled() {
        let vmOutput = sut.transform(input: vcOutput.eraseToAnyPublisher())
        let text = "Warsaw"
        
        vmOutput.sink { event in }.store(in: &cancellables)
        vcOutput.send(.didSearchLocation(text))
        
        XCTAssertEqual(locationsService.locationsCallCounter, 1)
    }
    
    func test_didSearchLocation_setsLocationsAndUpdatesView() {
        let vmOutput = sut.transform(input: vcOutput.eraseToAnyPublisher())
        locationsService.locations = [
            .init(localizedName: "Warsaw", cityKey: "key", country: .init(localizedName: "Poland")),
            .init(localizedName: "Wrocław", cityKey: "key", country: .init(localizedName: "Poland"))
        ]
        
        let text = "Warsaw"
        
        vmOutput.sink { event in
            switch event {
            case .fetchLocationsDidSucceed(let locations):
                XCTAssertEqual(locations.count, 2)
                XCTAssertEqual(locations[0].localizedName, "Warsaw")
                XCTAssertEqual(locations[1].localizedName, "Wrocław")
                XCTAssertEqual(locations[0].cityKey, "key")
                XCTAssertEqual(locations[1].country.localizedName, "Poland")
            }
        }.store(in: &cancellables)
        
        vcOutput.send(.didSearchLocation(text))
    }
    
    func test_didSearchLocation_selectsLocationAndGoesToDetails() {
        let vmOutput = sut.transform(input: vcOutput.eraseToAnyPublisher())
        let selectedLocation: LocationModel = .init(localizedName: "Warsaw", cityKey: "key", country: .init(localizedName: "Poland"))
        locationsService.locations = [
            selectedLocation,
            .init(localizedName: "Wrocław", cityKey: "key", country: .init(localizedName: "Poland"))
        ]
        
        vmOutput.sink { event in }
            .store(in: &cancellables)
        
        vcOutput.send(.didSelectLocation(selectedLocation))
        
        XCTAssertEqual(coordinatorMock.locationModelToGoToDetails?.cityKey, selectedLocation.cityKey)
        XCTAssertEqual(coordinatorMock.locationModelToGoToDetails?.localizedName, selectedLocation.localizedName)
        XCTAssertEqual(coordinatorMock.locationModelToGoToDetails?.country.localizedName, selectedLocation.country.localizedName)
    }
    
    final class LocationsServiceMock: LocationsServiceType {
        var locationsCallCounter = 0
        var locations = [LocationModel]()
        
        func getLocations(_ q: String) -> AnyPublisher<[LocationModel], any Error> {
            locationsCallCounter += 1
            
            return Just(locations)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    final class MainCoordinatorMock: Coordinator, LocationsCoordinatorProtocol {
        var navigationController: UINavigationController
        var locationModelToGoToDetails: LocationModel?
        
        init(navigationController: UINavigationController) {
            self.navigationController = navigationController
        }
        
        func start() {}
        
        func toDetails(_ model: LocationModel) {
            locationModelToGoToDetails = model
        }
    }
}
