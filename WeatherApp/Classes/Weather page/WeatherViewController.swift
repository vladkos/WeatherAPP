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
    private let output = PassthroughSubject<WeatherViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var weather: WeatherModel?
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let currentTemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 50)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let temperatureDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let minMaxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var weatherInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(locationLabel)
        stackView.addArrangedSubview(currentTemperatureLabel)
        stackView.addArrangedSubview(temperatureDescriptionLabel)
        stackView.addArrangedSubview(minMaxTemperatureLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initialization
    
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        observe()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        output.send(.viewDidAppear)
    }
    
    private func observe() {
        viewModel.transform(input: output.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchWeatherDidSucceed(let weather):
                    self?.weather = weather    
                    self?.currentTemperatureLabel.text = weather.currentTemperature.description
                    self?.temperatureDescriptionLabel.text = weather.temperatureDescription
                    self?.minMaxTemperatureLabel.text = "\(weather.minTemperature) - \( weather.maxTemperature)"
                case .handleCity(let city):
                    self?.locationLabel.text = city.localizedName
                }
            }.store(in: &cancellables)
    }
}

// MARK: - Setup View

extension WeatherViewController {
    private func setupView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        
        view.addSubview(weatherInfoStackView)
        
        NSLayoutConstraint.activate(
            [weatherInfoStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             weatherInfoStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            ])
    }
}

