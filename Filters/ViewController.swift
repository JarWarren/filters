//
//  ViewController.swift
//  Filters
//
//  Created by Jared Warren on 4/27/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var context = CIContext()
    var filterOne = CIFilter(name: "CITemperatureAndTint") // inputNeutral, inputTargetNeutral
    var filterTwo = CIFilter(name: "CIVibrance") // amount
    var filterThree = CIFilter(name: "CIHueAdjust") // angle
    var filterFour = CIFilter(name: "CISharpenLuminance") // sharpness
    var currentImage = #imageLiteral(resourceName: "sample0")
    
    // MARK: - Outlets
    
    @IBOutlet weak var filterImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSliders()
    }
    
    // MARK: - Private Methods
    
    private func setupSliders() {
        let startingImage = CIImage(image: currentImage)
        
        // temperature and tint
        filterOne?.setValue(startingImage, forKey: kCIInputImageKey)
        
        // vibrance
        filterTwo?.setValue(startingImage, forKey: kCIInputImageKey)
        filterTwo?.setValue(0, forKey: kCIInputAmountKey)
        filterThree?.setValue(startingImage, forKey: kCIInputImageKey)
        filterFour?.setValue(startingImage, forKey: kCIInputImageKey)
    }
    
    /**
     A "neutral" value is around 6,500. Lower values like 2-3,000 are very orange or "hot". Higher values like 12-14,000 are blue or "cold".
     Orange values are much denser than blue values (sliding left turns orange faster).
     Current slider range is 3,500 - 14,000 and starts at 6,500.
     
     CITemperatureAndTint takes inputNeutral && inputTargetNeutral, two different CIVectors.
     inputNeutral: Starts at [6,500, 0] by default and I'm leaving it.
     inputTargetNeutral: Same as above but I'm letting the user alter the X value.
     */
    private func processTemperature(_ value: Float) {
        let temperature = CIVector(x: CGFloat(value))
        filterOne?.setValue(temperature, forKey: "inputTargetNeutral")
        guard let output = filterOne?.outputImage,
            let processedImage = context.createCGImage(output, from: output.extent) else { return }
        filterImageView.image = UIImage(cgImage: processedImage)
    }
    
    /**
     Vibrance is measured from -1 - 1.
     */
    private func processVibrance(_ value: Float) {
        filterTwo?.setValue(value, forKey: kCIInputAmountKey)
        guard let output = filterTwo?.outputImage,
            let processed = context.createCGImage(output, from: output.extent) else { return }
        filterImageView.image = UIImage(cgImage: processed)
    }
    
    private func processHue(_ value: Float) {
        
    }
    
    // MARK: - Actions
    
    @IBAction func filterSliderValueChanged(_ sender: UISlider) { // temperature
        processTemperature(sender.value)
    }
    
    @IBAction func sliderTwoValueChanged(_ sender: UISlider) { // vibrance
        processVibrance(sender.value)
    }
    
    @IBAction func sliderThreeValueChanged(_ sender: UISlider) { // hue
        processHue(sender.value)
    }
}

/*
 @IBAction func blurSlider(_ sender: UISlider) {
 let originalImage = UIImage(named: "yourimage")// replace yourimage with the name of your image
 let currentValue = Int(sender.value)
 
 blur.maximumValue = 5
 blur.minimumValue = 0
 
 let currentFilter = CIFilter(name: "CIBoxBlur")
 currentFilter!.setValue(CIImage(image: originalImage!), forKey: kCIInputImageKey)
 currentFilter!.setValue(currentValue, forKey: kCIInputRadiusKey)
 
 let cropFilter = CIFilter(name: "CICrop")
 cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
 cropFilter!.setValue(CIVector(cgRect: (CIImage(image: originalImage!)?.extent)!), forKey: "inputRectangle")
 
 let output = cropFilter!.outputImage
 let cgimg = context.createCGImage(output!, from: output!.extent)
 let processedImage = UIImage(cgImage: cgimg!)
 imageView.image = processedImage
 
 }
 */
