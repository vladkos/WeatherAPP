//
//  Coordinator.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 07/08/2024.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}
