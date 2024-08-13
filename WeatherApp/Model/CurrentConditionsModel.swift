//
//  CurrentConditionsModel.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 12/08/2024.
//

import Foundation

struct CurrentConditionsModel: Decodable {
    let weatherText: String
    let temperature: Temperature
    
    func currentTemperatureValue(metric: Bool) -> Int {
        metric ? Int(temperature.metric.value) : Int(temperature.imperial.value)
    }
    
    func currentTemperature(metric: Bool) -> String {
        let metricValue: Temperature.Details.UnitType = metric ? .celsius : .fahrenheit
        return currentTemperatureValue(metric: metric).description + metricValue.value
    }
    
    private enum CodingKeys: String, CodingKey {
        case weatherText = "WeatherText"
        case temperature = "Temperature"
    }
    
    struct Temperature: Decodable {
        let metric: Details
        let imperial: Details
        
        private enum CodingKeys: String, CodingKey {
            case metric = "Metric"
            case imperial = "Imperial"
        }
        
        struct Details: Decodable {
            let value: Double
            let unit: UnitType
            
            private enum CodingKeys: String, CodingKey {
                case value = "Value"
                case unit = "Unit"
            }
            
            enum UnitType: String, Decodable {
                case fahrenheit = "F"
                case celsius = "C"
                
                var value: String {
                    switch self {
                    case .fahrenheit:
                        return "℉"
                    case .celsius:
                        return "℃"
                    }
                }
            }
        }
    }
}
