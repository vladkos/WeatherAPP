//
//  HourlyForecastCell.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 13/08/2024.
//

import UIKit

final class HourlyForecastCell: UICollectionViewCell {
    static var identifier = "HourlyForecastCell"
    
    @IBOutlet private weak var hourLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: "HourlyForecastCell", bundle: nil)
    }
    
    func configure(hour: String, value: String) {
        hourLabel.text = hour
        valueLabel.text = value
    }
}
