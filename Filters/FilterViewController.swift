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
    }
    
    func updateFilter(_ filter: Filter, value: Float) {
        guard let index = indices[filter.rawValue] else { return }
        filters[index].setValue(filter.updateValue(value), forKey: filter.updateKey)
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

enum Filter: String {
    case hue
    case temperature
    case vibrance
    
    func ciFilter() -> CIFilter? {
        switch self {
        case .hue:
            return CIFilter(name: "CIHueAdjust")
            
        case .temperature:
            return CIFilter(name: "CITemperatureAndTint")
            
        case .vibrance:
            return CIFilter(name: "CIVibrance")
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
    
    func updateValue(_ value: Float) -> Any {
        switch self {
        case .hue:
            return value
        case .temperature:
            return CIVector(x: CGFloat(value))
        case .vibrance:
            return value
        }
    }
}

/*
 class EditingViewController: UIViewController, MTKViewDelegate {
     @IBOutlet weak var slider: UISlider!
     @IBOutlet weak var mtkview: MTKView!

     var context : CIContext!
     let displayImage : CIImage! // must be set before viewDidLoad
     let vig = VignetteFilter()
     var queue: MTLCommandQueue!

     // slider value changed
     @IBAction func doSlider(_ sender: Any?) {
         self.mtkview.setNeedsDisplay()
     }

     override func viewDidLoad() {
         super.viewDidLoad()

         // preparation, all pure boilerplate

         self.mtkview.isOpaque = false // otherwise background is black
         // must have a "device"
         guard let device = MTLCreateSystemDefaultDevice() else {
             return
         }
         self.mtkview.device = device

         // mode: draw on demand
         self.mtkview.isPaused = true
         self.mtkview.enableSetNeedsDisplay = true

         self.context = CIContext(mtlDevice: device)
         self.queue = device.makeCommandQueue()

         self.mtkview.delegate = self
         self.mtkview.setNeedsDisplay()
     }

     func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
     }

     func draw(in view: MTKView) {
         // run the displayImage thru the CIFilter
         self.vig.setValue(self.displayImage, forKey: "inputImage")
         let val = Double(self.slider.value)
         self.vig.setValue(val, forKey:"inputPercentage")
         var output = self.vig.outputImage!

         // okay, `output` is the CIImage we want to display
         // scale it down to aspect-fit inside the MTKView
         var r = view.bounds
         r.size = view.drawableSize
         r = AVMakeRect(aspectRatio: output.extent.size, insideRect: r)
         output = output.transformed(by: CGAffineTransform(
             scaleX: r.size.width/output.extent.size.width,
             y: r.size.height/output.extent.size.height))
         let x = -r.origin.x
         let y = -r.origin.y

         // minimal dance required in order to draw: render, present, commit
         let buffer = self.queue.makeCommandBuffer()!
         self.context!.render(output,
             to: view.currentDrawable!.texture,
             commandBuffer: buffer,
             bounds: CGRect(origin:CGPoint(x:x, y:y), size:view.drawableSize),
             colorSpace: CGColorSpaceCreateDeviceRGB())
         buffer.present(view.currentDrawable!)
         buffer.commit()
     }
 }
 */
