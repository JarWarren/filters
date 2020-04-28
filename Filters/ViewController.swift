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
        
        filterTwo?.setValue(startingImage, forKey: kCIInputImageKey)
        filterThree?.setValue(startingImage, forKey: kCIInputImageKey)
        filterFour?.setValue(startingImage, forKey: kCIInputImageKey)
    }

    private func processTemperature(_ value: Float) {
        let temperature = CIVector(x: CGFloat(value))
        filterOne?.setValue(temperature, forKey: "inputTargetNeutral")
        guard let outputImage = filterOne?.outputImage,
            let processedImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
            filterImageView.image = UIImage(cgImage: processedImage)
    }
    
    private func processVibrance() {
        
    }
    
    private func processHue() {
        
    }
    
    // MARK: - Actions
    
    @IBAction func filterSliderValueChanged(_ sender: UISlider) { // temperature
        processTemperature(sender.value)
    }
    
    @IBAction func sliderTwoValueChanged(_ sender: UISlider) { // vibrance
        processVibrance()
    }
    
    @IBAction func sliderThreeValueChanged(_ sender: UISlider) { // hue
        processHue()
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
