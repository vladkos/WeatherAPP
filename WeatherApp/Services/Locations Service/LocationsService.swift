//
//  LocationsService.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 09/08/2024.
//

import Foundation
import Combine

final class LocationsService: LocationsServiceType {
    private let apiKey: String
    private let baseUrl: String
    
    init(
        apiKey: String = Constants.apiKey,
        baseUrl: String = Constants.baseUrl
    ) {
        self.apiKey = apiKey
        self.baseUrl = baseUrl
    }
    
    func getLocations(_ q: String) -> AnyPublisher<[LocationModel], Error> {
        let url = "\(baseUrl)/locations/v1/cities/autocomplete"
        let queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "q", value: q)
        ]
        var urlComps = URLComponents(string: url)!
        urlComps.queryItems = queryItems
        
        let request = URLRequest(url: urlComps.url!)
        return URLSession.shared.dataTaskPublisher(for: request)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }.map({ $0.data })
            .decode(type: [LocationModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
