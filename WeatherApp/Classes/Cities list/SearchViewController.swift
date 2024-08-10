//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 07/08/2024.
//

import UIKit
import Combine

final class SearchViewController: UIViewController {
    
    // MARK: - Properties
    private let searchController = UISearchController()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CityTableViewCell.nib(), forCellReuseIdentifier: CityTableViewCell.identifier)
        tableView.rowHeight = Constants.rowHeigh
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let viewModel: SearchViewModel
    private let output = PassthroughSubject<SearchViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var cities = [CityModel]()
    
    // MARK: - Initialization
    
    init(viewModel: SearchViewModel) {
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
    
    private func observe() {
        viewModel.transform(input: output.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchCitiesDidSucceed(let cities):
                    self?.cities = cities
                    self?.tableView.reloadData()
                }
            }.store(in: &cancellables)
    }
}

// MARK: - Setup View

extension SearchViewController {
    private func setupView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.title = Constants.title
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        
        title = Constants.title
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate(
            [tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
             tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
             tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
             tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CityTableViewCell.identifier,
            for: indexPath
        ) as? CityTableViewCell else { return UITableViewCell() }
        let city = cities[indexPath.item]
        cell.fill(city)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = cities[indexPath.item]
        output.send(.didSelectCity(city))
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text,
        text.isEmpty == false else {
            cities.removeAll()
            tableView.reloadData()
            return
        }
        output.send(.didSearchCity(text))
    }
}

// MARK: - Constants

extension SearchViewController {
    enum Constants {
        static let title = "Weather"
        static let rowHeigh: CGFloat = 50.0
    }
}
