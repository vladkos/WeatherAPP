//
//  CityTableViewCell.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 09/08/2024.
//

import UIKit

final class CityTableViewCell: UITableViewCell {
    static var identifier = "CityTableViewCell"
    
    @IBOutlet private  weak var titleLabel: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: "CityTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func fill(_ city: CityModel) {
        titleLabel.text = "\(city.localizedName), \(city.country.localizedName)"
    }
}
