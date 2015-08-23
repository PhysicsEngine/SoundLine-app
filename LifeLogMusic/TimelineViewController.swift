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
import SVProgressHUD

class TimelineViewController : UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    private var timeline: Timeline?
    private var player: AVAudioPlayer?
    private var refreshControl = UIRefreshControl()
//    private var timer = NSTimer(timeInterval: 1.0, target: self, selector: "didRefreshControl:", userInfo: nil, repeats: true)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 80.0
//        refreshControl.hidden = true
//        self.tableView.addSubview(refreshControl)
//        refreshControl.addTarget(self, action: "didRefreshControl:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        reloadTimeline()
    }
    
    // MARK: - Private
    
    func didRefreshControl(sender: AnyObject) {
        
        SVProgressHUD.show()
        SVProgressHUD.showWithStatus("Loading...", maskType: SVProgressHUDMaskType.Gradient)
        
        APIClient.sharedClient.timeline { (result) -> Void in
            SVProgressHUD.dismiss()
            
            self.timeline = result.value
            println("Count: \(self.timeline?.users.count)")
            
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    private func reloadTimeline() {
        APIClient.sharedClient.timeline { (result) -> Void in
            self.timeline = result.value
            println("Count: \(self.timeline?.users.count)")
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
                    self.player?.volume = 1.0
                    if let error = error {
                        println(error)
                        return
                    }
                    self.player!.play()
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