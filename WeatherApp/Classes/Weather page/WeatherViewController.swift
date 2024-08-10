//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 09/08/2024.
//

import UIKit
import Combine

final class WeatherViewController: UIViewController {
    
    private let viewModel: WeatherViewModel
    
    // MARK: - Initialization
    
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    
