//
//  ChainFilter.swift
//  Filters
//
//  Created by Jared Warren on 4/29/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit
import Metal

protocol ChainFilterDelegate: AnyObject {
    func imageDidUpdate(_ image: UIImage?)
}

class ChainFilter {
    
    weak var delegate: ChainFilterDelegate?
    var originalImage: UIImage?
    var processedImage: UIImage? {
        didSet {
            delegate?.imageDidUpdate(processedImage)
        }
    }
    
    private var filters = [CIFilter]()
    private var indices = [String: Int]()
    private var originalCIImage: CIImage!
    
    init(filters: Filter...) {
        for (i, filter) in filters.enumerated() {
            if let ciFilter = filter.ciFilter() {
                ciFilter.setDefaults()
                self.filters.append(ciFilter)
                indices[filter.rawValue] = i
            }
        }
    }
    
    func setImage(_ image: UIImage) {
        self.originalImage = image
        self.originalCIImage = CIImage(image: image)
        self.filters.first?.setValue(self.originalCIImage, forKey: "inputImage")
        self.updateImage()
    }
    
    func updateFilter(_ filter: Filter, value: Float) {
        guard let index = indices[filter.rawValue] else { return }
        filters[index].setValue(filter.updatedValue(value), forKey: filter.key)
        updateImage()
    }
    
    func resetFilters() {
        for cifilter in filters {
            if let filter = Filter(rawValue: cifilter.name) {
                cifilter.setValue(filter.initialValue(), forKey: filter.key)
            }
        }
        delegate?.imageDidUpdate(originalImage)
    }
    
    private func updateImage() {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        let context = CIContext(mtlDevice: device)
        
        for i in 0..<filters.count - 1 {
            let current = filters[i]
            let next = filters[i + 1]
            if let image = current.outputImage {
                next.setValue(image, forKey: "inputImage")
            }
        }

        let final = filters.last?.outputImage ?? CIImage.empty()
        let outputImage = context.createCGImage(final, from: self.originalCIImage.extent)!
        
        self.processedImage = UIImage(cgImage: outputImage)
    }
}
