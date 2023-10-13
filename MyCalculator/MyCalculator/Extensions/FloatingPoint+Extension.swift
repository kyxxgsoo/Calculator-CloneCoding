//
//  FloatingPoint+Extension.swift
//  MyCalculator
//
//  Created by Kyungsoo Lee on 2023/10/12.
//

import Foundation

extension FloatingPoint {
    var isInteger: Bool {
        return rounded() == self
    }
}
