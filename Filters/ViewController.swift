//
//  ViewController.swift
//  Filters
//
//  Created by Jingzhi Zhang on 04/07/17.
//  Copyright © 2017 NIU CS Department. All rights reserved.
//

import UIKit
import CoreImage


/* GLOBAL VARIABLES */
var CIFilterNames = [
    "CIPhotoEffectChrome",
    "CIPhotoEffectFade",
    "CIPhotoEffectInstant",
    "CIPhotoEffectNoir",
    "CIPhotoEffectProcess",
    "CIPhotoEffectTonal",
    "CIPhotoEffectTransfer",
    "CISepiaTone"
    //get information about other CIFilters, you may check the Core Image Filter Reference page https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
]



class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    /* Views */
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var imageToFilter: UIImageView!
    // Note: the UIImageView called imageToFilter overlays the originalImage, otherwise the app will not show you the processed image.
    
    @IBOutlet weak var filtersScrollView: UIScrollView!
    
    @IBAction func selectPicButton(_ sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler:{(action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            else {
                print("Camera is not available!")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler:{(action: UIAlertAction) in
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]){
        //if
            let pickedImage = info[UIImagePickerControllerOriginalImage] as!UIImage
        //{
        originalImage.image = pickedImage
        self.dismiss(animated: true, completion: nil)
        //}
        //else{
          //  print("Somrthing went wrong. ")
        //}
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
//hide the status bar from the screen
override var prefersStatusBarHidden : Bool {
    return true
}
    
    @IBAction func filterAction(_ sender: UIButton) {
        
        // Variables for setting the Font Buttons
        // These values are needed to place a row of buttons inside our filtersScrollView.
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 5
        let buttonWidth:CGFloat = 70
        let buttonHeight: CGFloat = 70
        let gapBetweenButtons: CGFloat = 5
        
        
        // Items Counter
        var itemCount = 0
        
        // Loop for creating buttons
        for i in 0..<CIFilterNames.count {
            itemCount = i
            
            // Button properties
            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
            filterButton.tag = itemCount
            filterButton.showsTouchWhenHighlighted = true
            filterButton.addTarget(self, action: #selector(ViewController.filterButtonTapped(_:)), for: .touchUpInside)
            filterButton.layer.cornerRadius = 6
            filterButton.clipsToBounds = true
            
            
            // Create filters for each button
            
            // Initialize a CIContext and CIImage to let Core Image work on originalImage (picture.jpg) that each button will show.
            let ciContext = CIContext(options: nil)
            let coreImage = CIImage(image: originalImage.image!)
            
            // Init a filter variable of type CIFilter
            let filter = CIFilter(name: "\(CIFilterNames[i])" )
            
            // Filter instance needs to set its default state, and then it becomes the input key for images.
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            
            // Create the data object from the filter and its image reference, which will be used to create a UIImage right away that will be attached to the button.
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            let imageForButton = UIImage(cgImage: filteredImageRef!);
            
            
            // Assign filtered image to the button as background image
            filterButton.setBackgroundImage(imageForButton, for: UIControlState())
            
            
            // Add Buttons as sub views to the filtersScrollView.
            xCoord +=  buttonWidth + gapBetweenButtons
            filtersScrollView.addSubview(filterButton)
        } // END LOOP
        
        
        // Set the contentSize of our ScrollView to fit all the buttons.
        // Converted to CGFloat (because CGSizeMake it doesn't accept Int values).
        filtersScrollView.contentSize = CGSize(width: buttonWidth * CGFloat(itemCount+2), height: yCoord)
        
    }
    

override func viewDidLoad() {
        super.viewDidLoad()
               
}
    

// FILTER BUTTON ACTION
func filterButtonTapped(_ sender: UIButton) {
    let button = sender as UIButton
        
    imageToFilter.image = button.backgroundImage(for: UIControlState())
}
    
    

    
// SAVE PICTURE BUTTON
@IBAction func savePicButton(_ sender: UIBarButtonItem) {
        // Save the image into camera roll
        UIImageWriteToSavedPhotosAlbum(imageToFilter.image!, nil, nil, nil)
        
        let alert = UIAlertView(title: "Filters",
                        message: "Your image has been saved to Photo Library",
                        delegate: nil,
                        cancelButtonTitle: "OK")
        alert.show()
}
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

