//
//  ViewController.swift
//  FoodWatch
//
//  Created by Gain Chang on 16/03/2019.
//  Copyright © 2019 Gain Chang. All rights reserved.
//

import UIKit
import VisualRecognitionV3

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let apiKey = "CeyE6zOv-v5gxA0fI4GlVA6yb4PB-8p1AG8z73eHYEop"
    let version = "2019-03-20"
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageVIew: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageVIew.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
            
            let imageData = image.jpegData(compressionQuality: 0.01)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("tempImg.jpg")
            
            try? imageData?.write(to: fileURL, options: [])
            
            visualRecognition.classify(imagesFile: fileURL, classifierIDs: ["food"]) {
                response, error in
                
                guard let result = response?.result else {
                    print(error?.localizedDescription ?? "unknown error")
                    return
                }
                
                let classes = result.images.first!.classifiers.first!.classes
                
                // for cleaning the result array
                self.classificationResults.removeAll()
                
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].className)
                }
                
                print(self.classificationResults)
            }
            
            
        } else {
            print("There was an error picking the image")
        }
        
    }

    
    @IBAction func libraryTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
}

