//
//  SignupViewController+ImagePicker.swift
//  Firebase+RxSwiftSample
//
//  Created by Ren Matsushita on 2020/02/14.
//  Copyright © 2020 Ren Matsushita. All rights reserved.
//

import UIKit

extension SignupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePicker(_ sourceType: UIImagePickerController.SourceType) {
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        imageView.image = image
        viewModel.imageData.accept(image.pngData())
        
        picker.dismiss(animated: true, completion: nil)
    }
}
