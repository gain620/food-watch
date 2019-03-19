//
//  ViewController.swift
//  FoodWatch
//
//  Created by Gain Chang on 16/03/2019.
//  Copyright © 2019 Gain Chang. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let apiKey = ""
    let version = "2019-03-20"
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var photoButton: UIBarButtonItem!
    @IBOutlet weak var imageVIew: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        cameraButton.isEnabled = false
        photoButton.isEnabled = false
        SVProgressHUD.show()
        
        
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
                
                //var tempStr = ""
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].className)
//                    tempStr += classes[index].className as! String
                }
                
                
                print(self.classificationResults)
                
                DispatchQueue.main.async {
                    self.navigationItem.title = self.classificationResults[0]
                    self.cameraButton.isEnabled = true
                    self.photoButton.isEnabled = true
                    SVProgressHUD.dismiss()
                }
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

