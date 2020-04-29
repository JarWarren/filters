//
//  FilterViewController.swift
//  Filters
//
//  Created by Jared Warren on 4/28/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit
import Metal

class FilterViewController: UIViewController {
    
    @IBOutlet weak var filterImageView: UIImageView!
    
    let filter = CompoundFilter(filters: .temperature,
                                .vibrance,
                                .hue)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filter.setImage(#imageLiteral(resourceName: "sample0"))
        filter.delegate = self
    }
    
    @IBAction func temperatureSliderValueChanged(_ sender: UISlider) {
        filter.updateFilter(.temperature, value: sender.value)
    }
    
    @IBAction func vibranceSliderValueChanged(_ sender: UISlider) {
        filter.updateFilter(.vibrance, value: sender.value)
    }
    
    @IBAction func hueSliderValueChanged(_ sender: UISlider) {
        filter.updateFilter(.hue, value: sender.value)
    }
    
}

extension FilterViewController: CompoundFilterDelegate {
    
    func imageDidUpdate(_ image: UIImage?) {
        filterImageView.image = image
    }
}

protocol CompoundFilterDelegate: AnyObject {
    func imageDidUpdate(_ image: UIImage?)
}

class CompoundFilter {
    
    weak var delegate: CompoundFilterDelegate?
    
    private var filters = [CIFilter]()
    private var indices = [String: Int]()
    
    init(filters: Filter...) {
        for (i, filter) in filters.enumerated() {
            if let ciFilter = filter.ciFilter() {
                self.filters.append(ciFilter)
                indices[filter.rawValue] = i
            }
        }
    }
    
    func setImage(_ image: UIImage) {
        self.filters.first?.setValue(image.cgImage, forKey: kCIInputImageKey)
    }
    
    func updateFilter(_ filter: Filter, value: Float) {
        guard let index = indices[filter.rawValue] else { return }
        filters[index].setValue(value, forKey: filter.updateKey)
        updateImage()
    }
    
    private func updateImage() {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        let context = CIContext(mtlDevice: device)
        
        for i in 0..<filters.count - 1 {
            filters[i+1].setValue(filters[i].outputImage, forKey: kCIInputImageKey)
        }
        
        let final = filters.last?.outputImage ?? CIImage.empty()
        let outputImage = context.createCGImage(final, from: final.extent)!
        
        delegate?.imageDidUpdate(UIImage(cgImage: outputImage))
    }
}

enum Filter: String {
    case hue
    case temperature
    case vibrance
    
    func ciFilter() -> CIFilter? {
        switch self {
        case .hue:
            return CIFilter(name: "CIHueAdjust",
                            parameters: ["inputAngle": 0])
            
        case .temperature:
            return CIFilter(name: "CITemperatureAndTint",
                            parameters: ["inputNeutral": CIVector(x: 6500), // fixed
                                "inputTargetNeutral": CIVector(x: 6500)])
            
        case .vibrance:
            return CIFilter(name: "CIVibrance",
                            parameters: ["inputAmount": 0])
        }
    }
    
    var updateKey: String {
        switch self {
        case .hue:
            return "inputAngle"
        case .temperature:
            return "inputTargetNeutral"
        case .vibrance:
            return "inputAmount"
        }
    }
}
