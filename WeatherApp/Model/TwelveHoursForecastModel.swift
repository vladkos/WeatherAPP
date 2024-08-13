//
//  TwelveHoursForecastModel.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 13/08/2024.
//

import Foundation

struct TwelveHoursForecastModel: Decodable {
    let temperature: Temperature
    let epochDateTime: Int
    
    var hourValue: Int {
        Calendar.current.component(.hour, from: Date(timeIntervalSince1970: TimeInterval(epochDateTime)))
    }
    
    private enum CodingKeys: String, CodingKey {
        case temperature = "Temperature"
        case epochDateTime = "EpochDateTime"
    }
    
    // MARK: - Temperature
    struct Temperature: Decodable {
        let value: Double
        let unit: String
        
        private enum CodingKeys: String, CodingKey {
            case value = "Value"
            case unit = "Unit"
        }
    }
}
