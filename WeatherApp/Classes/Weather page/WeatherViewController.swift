//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 09/08/2024.
//

import UIKit
import Combine

final class WeatherViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: WeatherViewModel
    private let output = PassthroughSubject<WeatherViewModel.Input, Never>()
    private let layout = UICollectionViewFlowLayout()
    private var cancellables = Set<AnyCancellable>()
    private var hourlyForecast = [TwelveHoursForecastModel]()
    
    // MARK: - Subviews
    
    private let metricSwitch: UISwitch = {
        let s = UISwitch()
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private let metricLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.text = "Metric ℃/℉"
        return label
    }()
    
    private let metricStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 25)
        return label
    }()
    
    private let currentTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 50)
        return label
    }()
    
    private let temperatureDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let minMaxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let weatherInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(HourlyForecastCell.nib(), forCellWithReuseIdentifier: HourlyForecastCell.identifier)
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 40, height: 100)
        collectionView.setCollectionViewLayout(layout, animated: true)
        return collectionView
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
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        output.send(.viewDidAppear)
    }
    
    private func bind() {
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
                case .handleLocation(let location):
                    self?.locationLabel.text = location.localizedName
                case .outputMetric(let metric):
                    self?.metricSwitch.isOn = metric
                case .outputTwelveHoursForecast(let weather):
                    self?.hourlyForecast = weather
                    self?.collectionView.reloadData()
                }
            }.store(in: &cancellables)
    }
    
    @objc private func switchValueDidChange(_ sender: UISwitch) {
        output.send(.metricDidChange(value: sender.isOn))
    }
    
    private func addSubviews() {
        view.addSubview(weatherInfoStackView)
        view.addSubview(metricStackView)
        view.addSubview(collectionView)
        
        metricStackView.addArrangedSubview(metricLabel)
        metricStackView.addArrangedSubview(metricSwitch)
        
        weatherInfoStackView.addArrangedSubview(locationLabel)
        weatherInfoStackView.addArrangedSubview(currentTemperatureLabel)
        weatherInfoStackView.addArrangedSubview(temperatureDescriptionLabel)
        weatherInfoStackView.addArrangedSubview(minMaxTemperatureLabel)
    }
    
    private func assignConstraints() {
        NSLayoutConstraint.activate(
            [
                weatherInfoStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                weatherInfoStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                metricStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                metricStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
                collectionView.heightAnchor.constraint(equalToConstant: 100),
                collectionView.topAnchor.constraint(equalTo: weatherInfoStackView.bottomAnchor),
            ]
        )
    }
    
    private func setupView() {
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .white
        
        metricSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        addSubviews()
        assignConstraints()
    }
}

// MARK: - UICollectionViewDataSource

extension WeatherViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hourlyForecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = hourlyForecast[indexPath.item]
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HourlyForecastCell.identifier,
            for: indexPath
        ) as! HourlyForecastCell
        cell.configure(
            hour: model.hourValue.description,
            value: Int(model.temperature.value).description + model.temperature.unit
        )
        return cell
    }
}
