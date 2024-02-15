//
//  ViewController.swift
//  Pizza App
//
//  Created by Evgeniy Zelinskiy on 15.02.2024.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var classificationResults: [VNClassificationObservation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }
    
    func detectCatOrDogOn(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            print("Error for loading model Inceptionv3")
            return
        }
        
        let request = VNCoreMLRequest(model: model) { vnRequest, error in
            guard let results = vnRequest.results as? [VNClassificationObservation], let firstResult = results.first else {
                print("Unexpected result type from VNCoreMLRequest")
                return
            }
            DispatchQueue.main.async {
                let isItPizza = firstResult.identifier.contains("pizza")
                self.title = isItPizza ? "It is pizza!" : "It is not pizza!"
                self.navigationController?.navigationBar.backgroundColor = isItPizza ? UIColor.green : UIColor.red
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Action

    @IBAction func сameraButtonTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            guard let ciimage = CIImage(image: image) else { return }
            detectCatOrDogOn(image: ciimage)
        }
    }
}

