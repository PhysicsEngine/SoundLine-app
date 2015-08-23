//
//  FilterViewController.swift
//  LifeLogMusic
//
//  Created by Yohei Yamaguchi on 8/22/15.
//  Copyright (c) 2015 PhysicalEngine. All rights reserved.
//

import UIKit
import SVProgressHUD

class FilterViewController : UIViewController {
    
    private enum EmotionType : String {
        case Happy = "happy"
        case Sad = "sad"
    }

    private var selectedButton: UIButton?
    private var emotion: EmotionType?
    var audio: NSData!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        sendButton.enabled = emotion != nil
    }
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func didTapSadButton(sender: UIButton) {
        sendButton.enabled = true
        
        selectedButton?.superview?.layer.borderWidth = 0
        
        selectedButton = sender
        
        emotion = .Sad
        
        sender.superview?.layer.borderColor = UIColor.blueColor().CGColor
        sender.superview?.layer.borderWidth = 3.0
        
        println("Sad!!!")
    }
    
    @IBAction func didTapHappyButton(sender: UIButton) {
        sendButton.enabled = true
        
        selectedButton?.superview?.layer.borderWidth = 0
        
        selectedButton = sender
        
        emotion = .Happy
        
        sender.superview?.layer.borderColor = UIColor.blueColor().CGColor
        sender.superview?.layer.borderWidth = 3.0
        
        println("Happy!!!")
    }
    
    @IBAction func didTapSendButton(sender: UIButton) {
        sender.enabled = false
        
        if let emotion = self.emotion {
            
            SVProgressHUD.show()
            SVProgressHUD.showWithStatus("Sending...", maskType: SVProgressHUDMaskType.Gradient)
            
            APIClient.sharedClient.upload(audio, emotion: emotion.rawValue, callback: { result in
                sender.enabled = true
                
                SVProgressHUD.dismiss()
                SVProgressHUD.showSuccessWithStatus("Done!")
                
                let delay = 1.0 * Double(NSEC_PER_SEC)
                let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                })
            })
        } else {
            sender.enabled = true
            UIAlertView(title: "Error", message: "Select the emotion.", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
}

// MARK: - UIAlertViewDelegate
extension FilterViewController : UIAlertViewDelegate {
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}