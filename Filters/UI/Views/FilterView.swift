//
//  FilterView.swift
//  Filters
//
//  Created by Jared Warren on 4/30/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import MetalKit
import AVKit

protocol FilterViewDelegate: AnyObject {
    func didPressFilterView()
    func didReleaseFilterView()
}

class FilterView: MTKView {
    
    weak var viewDelegate: FilterViewDelegate?
    var context: CIContext?
    var queue: MTLCommandQueue?
    
    func setUp(delegate: FilterViewDelegate) {
        self.viewDelegate = delegate
        self.device = MTLCreateSystemDefaultDevice()
        self.framebufferOnly = false
        if let device = device {
            self.queue = device.makeCommandQueue()
            self.context = CIContext(mtlDevice: device)
        }
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateWithImage(_ image: CIImage?) {
        guard var image = image else { return }
        // run the displayImage thru the CIFilter
        
        // okay, `output` is the CIImage we want to display
        // scale it down to aspect-fit inside the MTKView
        var r = bounds
        r.size = drawableSize
        r = AVMakeRect(aspectRatio: image.extent.size, insideRect: r)
        image = image.transformed(by: CGAffineTransform(
            scaleX: r.size.width/image.extent.size.width,
            y: r.size.height/image.extent.size.height))
        let x = -r.origin.x
        let y = -r.origin.y
        
        let buffer = queue?.makeCommandBuffer()
        // minimal dance required in order to draw: render, present, commit
        context?.render(image,
                        to: currentDrawable!.texture,
                        commandBuffer: buffer,
                        bounds: CGRect(origin: CGPoint(x: x, y: y), size: drawableSize),
                        colorSpace: CGColorSpaceCreateDeviceRGB())
        buffer?.present(currentDrawable!)
        buffer?.commit()
        draw()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewDelegate?.didPressFilterView()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewDelegate?.didReleaseFilterView()
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
