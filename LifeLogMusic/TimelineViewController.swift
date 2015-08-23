//
//  TimelineViewController.swift
//  LifeLogMusic
//
//  Created by Yohei Yamaguchi on 8/22/15.
//  Copyright (c) 2015 PhysicalEngine. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class TimelineViewController : UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    private var timeline: Timeline?
    private var player: AVAudioPlayer?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 80.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        APIClient.sharedClient.timeline { (result) -> Void in
            self.timeline = result.value
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension TimelineViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let message = timeline?.users[indexPath.row] {
            APIClient.sharedClient.download(message.userName, filename: message.fileName, callback: { (result) -> Void in
                if let data = result.value {
                    let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
                    let filePath = NSString(format: "%@/%@.m4a", dir, NSUUID().UUIDString)
                    data.writeToFile(filePath as String, atomically: true)
                    let URL = NSURL(string: filePath as String)!
                    
                    var error:NSError?
                    self.player = AVAudioPlayer(contentsOfURL: URL, error: &error)
                    if let error = error {
                        println(error)
                        return
                    }
                    self.player?.play()
                }
            })
        }
    }

}

extension TimelineViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timeline?.users.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCellID", forIndexPath: indexPath) as! TableViewCell
        cell.usernameLabel.text = timeline?.users[indexPath.row].userName
        cell.filenameLabel.text = timeline?.users[indexPath.row].fileName;
        return cell
    }
    
    
}