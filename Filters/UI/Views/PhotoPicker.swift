//
//  PhotoPicker.swift
//  Filters
//
//  Created by Jared Warren on 4/29/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit

/// Methods for a PhotoPicker to notify its delegate when it is ready to be presented or when the user has selected an image/cancelled.
protocol PhotoPickerDelegate: AnyObject {
    func didFinishPicking(image: UIImage?)
    func readyToPresent(_ viewController: UIViewController)
}

/// Wrapper around `UIImagePickerController` which handles presentation and fetching the image.
// TOOD: let user decide whether it's editing mode or not
class PhotoPicker: NSObject, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    weak var delegate: PhotoPickerDelegate?
    var imagePickerController = UIImagePickerController()
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        self.imagePickerController.delegate = self
    }
    
    // MARK: - Interface Methods
    
    func present(from view: UIView) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let action = UIAlertAction(title: "Take Photo", style: .default) { [weak self] (_) in
                guard let picker = self?.imagePickerController else { return }
                self?.imagePickerController.sourceType = .camera
                self?.delegate?.readyToPresent(picker)
            }
            sheet.addAction(action)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let action = UIAlertAction(title: "Photo Library", style: .default) { [weak self] (_) in
                guard let picker = self?.imagePickerController else { return }
                self?.imagePickerController.sourceType = .photoLibrary
                self?.delegate?.readyToPresent(picker)
            }
            sheet.addAction(action)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            let action = UIAlertAction(title: "Camera Roll", style: .default) { [weak self] (_) in
                guard let picker = self?.imagePickerController else { return }
                self?.imagePickerController.sourceType = .savedPhotosAlbum
                self?.delegate?.readyToPresent(picker)
            }
            sheet.addAction(action)
        }
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            sheet.popoverPresentationController?.sourceView = view
            sheet.popoverPresentationController?.sourceRect = view.bounds
            sheet.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.delegate?.readyToPresent(sheet)
    }
    
    // MARK: - Private Methods
    
    private func didFinishPicking(image: UIImage?) {
        imagePickerController.dismiss(animated: true)
        delegate?.didFinishPicking(image: image)
    }
}

extension PhotoPicker: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        didFinishPicking(image: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let imageSource: UIImagePickerController.InfoKey = picker.allowsEditing ? .editedImage : .originalImage
        let image = info[imageSource] as? UIImage
        didFinishPicking(image: image)
    }
}
