//
//  CameraViewController.swift
//  Filters
//
//  Created by Jared Warren on 4/28/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var filterView: FilterView!
    @IBOutlet weak var temperatureSlider: UISlider!
    @IBOutlet weak var vibranceSlider: UISlider!
    @IBOutlet weak var hueSlider: UISlider!
    @IBOutlet weak var sharpnessSlider: UISlider!
    
    // MARK: - Properties
    
    let photoPicker = PhotoPicker()
    let chain = ChainFilter(filters: .temperature,
                            .vibrance,
                            .hue,
                            .sharpness)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterView.setUp(delegate: self)
        photoPicker.delegate = self
        chain.setImage(#imageLiteral(resourceName: "sample0"))
        chain.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction func undoButtonTapped(_ sender: Any) {
        chain.resetFilters()
        temperatureSlider.value = 6500
        vibranceSlider.value = 0
        hueSlider.value = 0
        sharpnessSlider.value = 0.4
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        photoPicker.present(from: self.view)
    }
    
    @IBAction func temperatureSliderValueChanged(_ sender: UISlider) {
        chain.updateFilter(.temperature, value: sender.value)
    }
    
    @IBAction func vibranceSliderValueChanged(_ sender: UISlider) {
        chain.updateFilter(.vibrance, value: sender.value)
    }
    
    @IBAction func hueSliderValueChanged(_ sender: UISlider) {
        chain.updateFilter(.hue, value: sender.value)
    }
    
    @IBAction func sharpnessSliderValueChanged(_ sender: UISlider) {
        chain.updateFilter(.sharpness, value: sender.value)
    }
    
}

extension CameraViewController: FilterViewDelegate {
    func didPressFilterView() {
        filterView.updateWithImage(chain.originalImage)
    }
    
    func didReleaseFilterView() {
        filterView.updateWithImage(chain.processedImage)
    }
}

extension CameraViewController: ChainFilterDelegate {
    
    func imageDidUpdate(_ image: CIImage?) {
        filterView.updateWithImage(image)
    }
}

extension CameraViewController: PhotoPickerDelegate {
    
    func readyToPresent(_ viewController: UIViewController) {
        present(viewController, animated: true)
    }
    
    func didFinishPicking(image: UIImage?) {
        if let image = image {
            chain.setImage(image)
        }
    }
}
