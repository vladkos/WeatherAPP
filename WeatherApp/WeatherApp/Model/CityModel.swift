//
//  CityModel.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 07/08/2024.
//

import Foundation

struct CityModel {
    let localizedName: String
}

extension CityModel: Codable {
    private enum CodingKeys: String, CodingKey {
        case localizedName = "LocalizedName"
    }
}
