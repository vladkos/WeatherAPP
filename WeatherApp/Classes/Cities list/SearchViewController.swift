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
    
    private let viewModel: SearchViewModel
    private let output = PassthroughSubject<SearchViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var locations = [LocationModel]()
    
    // MARK: - Subviews
    
    private let searchController = UISearchController()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(LocationTableViewCell.nib(), forCellReuseIdentifier: LocationTableViewCell.identifier)
        return tableView
    }()
    
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
        bind()
    }
    
    private func bind() {
        viewModel.transform(input: output.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchLocationsDidSucceed(let locations):
                    self?.locations = locations
                    self?.tableView.reloadData()
                }
            }.store(in: &cancellables)
    }
    
    private func assignConstraints() {
        NSLayoutConstraint.activate(
            [
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
    }
    
    private func setupView() {
        title = viewModel.title()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.title = viewModel.title()
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.searchTextField.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addSubviews()
        assignConstraints()
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LocationTableViewCell.identifier,
            for: indexPath
        ) as? LocationTableViewCell else {
            return UITableViewCell()
        }
        
        let location = locations[indexPath.item]
        cell.fill(location)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        .tableViewCellHeight
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locations[indexPath.item]
        output.send(.didSelectLocation(location))
    }
}

// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text,
        text.isEmpty == false else {
            locations.removeAll()
            tableView.reloadData()
            return
        }
        output.send(.didSearchLocation(text))
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text,
              let textRange = Range(range, in: text) else {
            return false
        }
        let updatedText = text.replacingCharacters(in: textRange, with: string)

        return updatedText.isValidSearch
    }
}
