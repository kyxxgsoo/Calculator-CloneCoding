//
//  UIColor+Extension.swift
//  MyCalculator
//
//  Created by Kyungsoo Lee on 2023/10/11.
//

import UIKit

extension UIColor {
    static func colorFromString(_ string: String) -> UIColor {
        switch string {
        case "lightGray":
            return .lightGray
        case "systemOrange":
            return .systemOrange
        case "darkGray":
            return .darkGray
        case "white":
            return .white
        default:
            return .clear
        }
    }
}
