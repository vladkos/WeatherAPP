//
//  String+Extension.swift
//  WeatherApp
//
//  Created by Vlad Kostenko on 13/08/2024.
//

import Foundation

extension String {
    var isValidSearch: Bool {
        let characterset = CharacterSet(charactersIn: "AaĄąBbCcĆćDdEeĘęFfGgHhIiJjKkLlŁłMmNnŃńOoÓóPpRrSsŚśTtUuWwYyZzŹźŻż' ")
        if self.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        }
        return true
    }
}
