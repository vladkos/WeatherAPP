//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 07/08/2024.
//

import Foundation

struct WeatherModel: Codable {
    let dailyForecasts: [DailyForecasts]
    
    var minTemperature: Int {
        Int(dailyForecasts.first?.temperature.minimum.value ?? 0)
    }
    var maxTemperature: Int {
        Int(dailyForecasts.first?.temperature.maximum.value ?? 0)
    }
    var currentTemperature: Int {
        (maxTemperature + minTemperature) / 2
    }
    var temperatureDescription: String {
        "temp descr"
    }
    
    private enum CodingKeys: String, CodingKey {
        case dailyForecasts = "DailyForecasts"
    }
}

// MARK: - DailyForecasts
struct DailyForecasts: Codable {
    let temperature: Temperature
    
    private enum CodingKeys: String, CodingKey {
        case temperature = "Temperature"
    }
}

// MARK: - Temperature
struct Temperature: Codable {
    let minimum: Minimum
    let maximum: Maximum

    private enum CodingKeys: String, CodingKey {
        case minimum = "Minimum"
        case maximum = "Maximum"
    }
}


// MARK: - Minimum
struct Minimum: Codable {
    let value: Double

    private enum CodingKeys: String, CodingKey {
        case value = "Value"
    }
}


// MARK: - Minimum
struct Maximum: Codable {
    let value: Double

    private enum CodingKeys: String, CodingKey {
        case value = "Value"
    }
}
