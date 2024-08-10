//
//  MainCoordinator.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 07/08/2024.
//

import UIKit

final class MainCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Start Coordinator
    
    func start() {
        let searchViewModel = SearchViewModel(coordinator: self)
        let mainController = SearchViewController(viewModel: searchViewModel)
        navigationController.pushViewController(mainController, animated: true)
    }

    // MARK: - Navigate To Details Screen

    func toDetails(_ model: CityModel) {
        let weatherViewModel = WeatherViewModel(coordinator: self, cityModel: model)
        let weatherViewController = WeatherViewController(viewModel: weatherViewModel)
        navigationController.pushViewController(weatherViewController, animated: true)
    }
}
