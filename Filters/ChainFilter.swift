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
    
    private var filters = [CIFilter]()
    private var indices = [String: Int]()
    private var image: CIImage!
    
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
        self.image = CIImage(image: image)
        self.filters.first?.setValue(self.image, forKey: "inputImage")
        self.updateImage()
    }
    
    func updateFilter(_ filter: Filter, value: Float) {
        guard let index = indices[filter.rawValue] else { return }
        filters[index].setValue(filter.updatedValue(value), forKey: filter.key)
        updateImage()
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
        let outputImage = context.createCGImage(final, from: self.image.extent)!
        
        delegate?.imageDidUpdate(UIImage(cgImage: outputImage))
    }
}
