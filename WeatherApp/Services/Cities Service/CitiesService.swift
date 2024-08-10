//
//  CitiesService.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 09/08/2024.
//

import Foundation
import Combine

final class CitiesService: CitiesServiceType {
    
    func getCities(_ q: String) -> AnyPublisher<[CityModel], Error> {
        let baseUrl = "http://dataservice.accuweather.com/locations/v1/cities/autocomplete"
        let queryItems = [
            URLQueryItem(name: "apikey", value: "muSApLyJoXuvUvLTEDSPmaCbYCawJndA"),
            URLQueryItem(name: "q", value: q)
        ]
        var urlComps = URLComponents(string: baseUrl)!
        urlComps.queryItems = queryItems
        let request = URLRequest(url: urlComps.url!)
        return URLSession.shared.dataTaskPublisher(for: request)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }.map({ $0.data })
            .decode(type: [CityModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
