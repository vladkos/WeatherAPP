//
//  CityModel.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 07/08/2024.
//

import Foundation

struct CityModel: Decodable {
    let localizedName: String
    let cityKey: String
    let country: CountryModel

    private enum CodingKeys: String, CodingKey {
        case localizedName = "LocalizedName"
        case cityKey = "Key"
        case country = "Country"
    }
}

struct CountryModel: Decodable {
    let localizedName: String
    
    private enum CodingKeys: String, CodingKey {
        case localizedName = "LocalizedName"
    }
}
