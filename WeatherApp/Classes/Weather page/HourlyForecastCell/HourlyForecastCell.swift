//
//  HourlyForecastCell.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 13/08/2024.
//

import UIKit

final class HourlyForecastCell: UICollectionViewCell {

    @IBOutlet private weak var hourLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(hour: String, value: String) {
        hourLabel.text = hour
        valueLabel.text = value
    }
}
