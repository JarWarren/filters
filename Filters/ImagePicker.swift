//
//  ImagePicker.swift
//  Filters
//
//  Created by Jared Warren on 4/29/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

open class ImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {
    
}

protocol PhotoPickerDelegate: AnyObject {
    func didFinishPicking(image: UIImage?)
    func readyToPresent(_ viewController: UIViewController)
}

class PhotoPicker: NSObject, UINavigationControllerDelegate {
    
    weak var delegate: PhotoPickerDelegate?
    var imagePickerController = UIImagePickerController()
    
    override init() {
        super.init()
        self.imagePickerController.delegate = self
    }
    
    private func didFinishPicking(image: UIImage?) {
        imagePickerController.dismiss(animated: true)
        delegate?.didFinishPicking(image: image)
    }
    
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
