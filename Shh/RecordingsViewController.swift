//
//  RecordingsViewController.swift
//  Shh
//
//  Created by Matt Lebl on 2016-04-26.
//  Copyright © 2016 Matt Lebl. All rights reserved.
//

import UIKit
import AudioKit

// MARK: RecordingsViewController

class RecordingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentlyPlaying = false
    var currentPlayingID = ""
    var player: AKAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        player = AKAudioPlayer(NSBundle.mainBundle().pathForResource("silence", ofType: "wav")!)
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        AudioKit.stop()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func playRecording(id id: String) {
        for cell in tableView.visibleCells {
            if let recordingCell = cell as? RecordingCell {
                if recordingCell.id == id {
                    recordingCell.playButton.setTitle("Stop", forState: .Normal)
                } else {
                    recordingCell.playButton.enabled = false
                }
            }
        }
        let recording = Recording()
        currentPlayingID = id
        currentlyPlaying = true
        player = AKAudioPlayer(recording.getDocumentsPath().stringByAppendingPathComponent("\(id).wav"))
        AudioKit.output = player
        AudioKit.start()
        player.reloadFile()
        player.start()
    }
    
    func stopPlaying() {
        for cell in tableView.visibleCells {
            if let recordingCell = cell as? RecordingCell {
                recordingCell.playButton.setTitle("Play", forState: .Normal)
                recordingCell.playButton.enabled = true
            }
        }
        currentlyPlaying = false
        player.stop()
        AudioKit.stop()
    }
    
}

// MARK: - Table View Delegate

extension RecordingsViewController: UITableViewDelegate {
    
}

// MARK: - Table View Data Source

extension RecordingsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let recording = Recording()
        return recording.getRecordingIDs().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let recording = Recording()
        let id = recording.getRecordingIDs()[indexPath.row]
        let recordingInfo = recording.getInfoOnID(id: id)
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! RecordingCell
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        cell.nameLabel.text = recordingInfo?.name
        
        // This is a train wreck
        cell.dateLabel.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: NSTimeInterval((recordingInfo?.time)!)))
        
        if currentlyPlaying {
            if currentPlayingID == id {
                cell.playButton.enabled = true
                cell.playButton.setTitle("Stop", forState: .Normal)
            } else {
                cell.playButton.enabled = false
                cell.playButton.setTitle("Play", forState: .Normal)
            }
        } else {
            cell.playButton.enabled = true
            cell.playButton.setTitle("Play", forState: .Normal)
        }
        
        cell.playButton.enabled = currentlyPlaying ? id == currentPlayingID : true
        
        cell.id = id
        cell.delegate = self
        
        return cell
    }
    
}