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
    var audio: NSData!
    
    // MARK: - IBOutlet/IBAction
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
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
        
        if recorder == nil {
            return
        }
        
        println("stop")
        self.recorder?.stop()
//        self.meterTimer.invalidate()
        
        //self.recordButton.setTitle("Record", forState:.Normal)
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setActive(false, error: &error) {
            println("could not make session inactive")
            if let e = error {
                println(e.localizedDescription)
                return
            }
        }
//        self.stopButton.enabled = false
//        self.recordButton.enabled = true
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let filterVC = segue.destinationViewController as? FilterViewController {
            filterVC.audio = audio
        }
    }
    
}

// MARK: - AVAudioRecorderDelegate
extension RecordingViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        println("finished recording \(flag)")
        
        recordButton.setTitle("Record", forState:.Normal)
        
        self.audio = NSData(contentsOfURL:recorder.url, options:nil, error:nil)!
        println("DataSize: \(self.audio.length)")
        
        self.performSegueWithIdentifier("toFilter", sender: nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println("\(error.localizedDescription)")
    }
    
}