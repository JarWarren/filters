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
