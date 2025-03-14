//
//  ImageSaver.swift
//  UberSnapTest
//
//  Created by Vincent on 14/03/25.
//

import Foundation

class ImageSaver: NSObject, ObservableObject {
    @Published var isDisplayingAlert = false
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            isDisplayingAlert = true
        } else {
            print("Error \(error?.localizedDescription ?? "")")
        }
    }
}
