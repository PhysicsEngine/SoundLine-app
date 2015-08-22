//
//  RecordingViewController.swift
//  LifeLogMusic
//
//  Created by Yohei Yamaguchi on 8/22/15.
//  Copyright (c) 2015 PhysicalEngine. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController : UIViewController {
    
    // MARK: - Property
    
    var recorder: AVAudioRecorder?
    
    // MARK: - IBOutlet/IBAction
    
    @IBAction func didTapRecordButton(sender: UIButton) {
        if let recorder = recorder where recorder.recording {
            recorder.pause()
            sender.setTitle("Continue", forState:.Normal)
        } else {
            sender.enabled = true
            sender.setTitle("Pause", forState:.Normal)
            self.recordWithPermission(true)
        }
    }
    
    @IBAction func didTapStopButton(sender: UIButton) {
    }
    
    @IBOutlet weak var displayLabel: UILabel!
  
    // MARK: - Private
    
    func recordWithPermission(setup:Bool) {
        let session = AVAudioSession.sharedInstance()
        // ios 8 and later
        if session.respondsToSelector("requestRecordPermission:") {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    println("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder?.record()
                 } else {
                    println("Permission to record not granted")
                }
            }
        } else {
            println("requestRecordPermission unrecognized")
        }
    }
    
    func setSessionPlayAndRecord() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
    
    func setupRecorder() {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask,true)
        var docsDir: AnyObject = dirPaths[0]
        var soundFilePath = docsDir.stringByAppendingPathComponent("Recorded.m4a")
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        var recordSettings = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        
        var error: NSError?
        self.recorder = AVAudioRecorder(URL: soundFileURL!, settings: recordSettings as [NSObject : AnyObject], error: &error)
        if let e = error {
            println(e.localizedDescription)
        } else {
            self.recorder?.delegate = self
            self.recorder?.meteringEnabled = true
            self.recorder?.prepareToRecord() // creates/overwrites the file at soundFileURL
            
        }
    }
    
}

// MARK: - AVAudioRecorderDelegate
extension RecordingViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!,
        successfully flag: Bool) {
            println("finished recording \(flag)")
            //recordButton.setTitle("Record", forState:.Normal)
            
            // iOS8 and later
            var alert = UIAlertController(title: "Recorder",
                message: "Finished Recording",
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Keep", style: .Default, handler: {action in
                println("keep was tapped")
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: {action in
                println("delete was tapped")
                //self.recorder.deleteRecording()
                self.recorder = nil
                
            }))
            self.presentViewController(alert, animated:true, completion:nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!,
        error: NSError!) {
            println("\(error.localizedDescription)")
    }
}