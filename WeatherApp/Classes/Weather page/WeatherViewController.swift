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
    
    private lazy var fOrCSwitch: UISwitch = {
        let s = UISwitch()
        s.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    private let metricLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.text = "Metric C/F"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var metricStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(metricLabel)
        stackView.addArrangedSubview(fOrCSwitch)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
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
                case .outputMinMaxTemperature(let minMax):
                    self?.minMaxTemperatureLabel.text = minMax
                case .outputCurrentTemperature(let currentTemperature, let color):
                    self?.currentTemperatureLabel.text = currentTemperature
                    self?.currentTemperatureLabel.textColor = color
                case .outputWeatherDescription(let description):
                    self?.temperatureDescriptionLabel.text = description
                case .handleCity(let city):
                    self?.locationLabel.text = city.localizedName
                case .outputMetric(let metric):
                    self?.fOrCSwitch.isOn = metric
                }
            }.store(in: &cancellables)
    }
    
    @objc private func switchValueDidChange(_ sender: UISwitch) {
        output.send(.metricDidChange(value: sender.isOn))
    }
}

// MARK: - Setup View

extension WeatherViewController {
    private func setupView() {
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .white
        
        view.addSubview(weatherInfoStackView)
        view.addSubview(metricStackView)
        
        NSLayoutConstraint.activate(
            [weatherInfoStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             weatherInfoStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             metricStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
             metricStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            ])
    }
}

