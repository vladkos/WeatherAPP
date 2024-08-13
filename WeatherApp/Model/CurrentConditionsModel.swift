//
//  CurrentConditionsModel.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 12/08/2024.
//

import Foundation

struct CurrentConditionsModel: Codable {
    let weatherText: String
    let temperature: Temperature
    
    func currentTemperature(metric: Bool) -> String {
        switch metric {
        case true:
            return "\(Int(temperature.metric.value))\(temperature.metric.unit.rawValue)"
        case false:
            return "\(Int(temperature.imperial.value))\(temperature.imperial.unit.rawValue)"
        }
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case weatherText = "WeatherText"
        case temperature = "Temperature"
    }
    
    struct Temperature: Codable {
        let metric: Details
        let imperial: Details
        
        private enum CodingKeys: String, CodingKey {
            case metric = "Metric"
            case imperial = "Imperial"
        }
        
        struct Details: Codable {
            let value: Double
            let unit: UnitType
            
            
            private enum CodingKeys: String, CodingKey {
                case value = "Value"
                case unit = "Unit"
            }
            
            enum UnitType: String, Codable {
                case fahrenheit = "F"
                case celsius = "C"
            }
        }
    }
}
