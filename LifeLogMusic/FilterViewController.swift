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
    
    private var emotion: EmotionType?
    var audio: NSData!
    
    @IBAction func didTapSadButton(sender: UIButton) {
        emotion = .Sad
        //sender.superview?.
        println("Sad!!!")
    }
    
    @IBAction func didTapHappyButton(sender: UIButton) {
        emotion = .Happy
        println("Happy!!!")
    }
    
    @IBAction func didTapSendButton(sender: UIButton) {
        sender.enabled = false
        
        if let emotion = self.emotion {
            
            SVProgressHUD.show()
            SVProgressHUD.showWithStatus("送信中です", maskType: SVProgressHUDMaskType.Gradient)
            
            APIClient.sharedClient.upload(audio, emotion: emotion.rawValue, callback: { result in
                sender.enabled = true
                
                SVProgressHUD.dismiss()
                SVProgressHUD.showSuccessWithStatus("送信完了")
                
                let delay = 3.0 * Double(NSEC_PER_SEC)
                let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                })
            })
        } else {
            sender.enabled = true
            UIAlertView(title: "Error", message: "感情を選んでください", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
}

// MARK: - UIAlertViewDelegate
extension FilterViewController : UIAlertViewDelegate {
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}