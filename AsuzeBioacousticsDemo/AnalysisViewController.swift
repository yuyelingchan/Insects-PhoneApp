//
//  AnalysisViewController.swift
//  AzureBioacousticsDemo
//
//  Created by acr on 21/07/2015.
//  Copyright (c) 2015 University of Southampton. All rights reserved.
//

import UIKit

class AnalysisViewController : UIViewController {
    
    var image:UIImage?
    var message:String?
    
    @IBOutlet var doneButton:UIButton?
    
    @IBOutlet var resultsLabel:UILabel?
    
    @IBOutlet var resultsImage:UIImageView?
    
    @IBAction func doneButtonPressed(sender: AnyObject?) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        
        if message != nil {
            
            resultsLabel?.text = message
        
        }
        
        if image != nil {
            
            resultsImage?.image = image
            
        }
 
    }
    
    override func shouldAutorotate() -> Bool {
        
        return true
        
    }
    
    override func supportedInterfaceOrientations() -> Int {
        
        return Int((UIInterfaceOrientationMask.Portrait | UIInterfaceOrientationMask.PortraitUpsideDown).rawValue)
        
    }
    
}