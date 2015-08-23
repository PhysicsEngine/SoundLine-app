//
//  FilterViewController.swift
//  LifeLogMusic
//
//  Created by Yohei Yamaguchi on 8/22/15.
//  Copyright (c) 2015 PhysicalEngine. All rights reserved.
//

import UIKit

class FilterViewController : UIViewController {
    
    private enum EmotionType : String {
        case Happy = "happy"
        case Sad = "sad"
    }
    
    private var emotion: EmotionType?
    var audio: NSData!
    
    @IBAction func didTapSadButton(sender: UIButton) {
        emotion = .Sad
        sender.superview?.
        println("Sad!!!")
    }
    
    @IBAction func didTapHappyButton(sender: UIButton) {
        emotion = .Happy
        println("Happy!!!")
    }
    
    @IBAction func didTapSendButton(sender: UIButton) {
        
        if let emotion = self.emotion {
            APIClient.sharedClient.upload(audio, emotion: emotion.rawValue, callback: { result in
                println(result)
                })
        } else {
            UIAlertView(title: "Error", message: "感情を選んでください", delegate: nil, cancelButtonTitle: "キャンセル").show()
        }
    }
}