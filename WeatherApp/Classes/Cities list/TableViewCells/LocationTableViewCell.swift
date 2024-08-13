//
//  LocationTableViewCell.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 09/08/2024.
//

import UIKit

final class LocationTableViewCell: UITableViewCell {
    static var identifier = "LocationTableViewCell"
    
    @IBOutlet private  weak var titleLabel: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: "LocationTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        accessoryType = .disclosureIndicator
    }

    func fill(_ location: LocationModel) {
        titleLabel.text = "\(location.localizedName), \(location.country.localizedName)"
    }
}
