//
//  Filter.swift
//  Filters
//
//  Created by Jared Warren on 4/29/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import CoreImage

enum Filter: String {
    case hue
    case sharpness
    case temperature
    case vibrance
    
    func ciFilter() -> CIFilter? {
        switch self {
        case .hue:
            return CIFilter(name: "CIHueAdjust")
            
        case .sharpness:
            return CIFilter(name: "CISharpenLuminance")
            
        case .temperature:
            return CIFilter(name: "CITemperatureAndTint")
            
        case .vibrance:
            return CIFilter(name: "CIVibrance")
        }
    }
    
    var key: String {
        switch self {
        case .hue:
            return "inputAngle"
        case .sharpness:
            return "inputSharpness"
        case .temperature:
            return "inputTargetNeutral"
        case .vibrance:
            return "inputAmount"
        }
    }
    
    func updatedValue(_ value: Float) -> Any {
        switch self {
        case .hue:
            return value
        case .sharpness:
            return value
        case .temperature:
            return CIVector(x: CGFloat(value))
        case .vibrance:
            return value
        }
    }
}
