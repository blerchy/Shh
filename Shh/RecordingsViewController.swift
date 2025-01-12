//
//  RecordingsViewController.swift
//  Shh
//
//  Created by Matt Lebl on 2016-04-26.
//  Copyright © 2016 Matt Lebl. All rights reserved.
//

import UIKit
import AudioKit
import CleanroomLogger

// MARK: RecordingsViewController

class RecordingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var timer = NSTimer()
    
    var currentlyPlaying = false
    var currentPlayingID = ""
    var player: AKAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        player = AKAudioPlayer(NSBundle.mainBundle().pathForResource("silence", ofType: "wav")!)
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
        let asset = AVURLAsset(URL: NSURL(fileURLWithPath: recording.getDocumentsPath().stringByAppendingPathComponent("\(id).wav")))
        let duration = asset.duration
        AudioKit.output = player
        AudioKit.start()
        player.reloadFile()
        player.start()
        timer = NSTimer.scheduledTimerWithTimeInterval(CMTimeGetSeconds(duration), target: self, selector: #selector(self.stopPlaying), userInfo: nil, repeats: false)
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
    
    func share(id id: String) {
        fatalError("RecordingsViewController.share(:) is unimplemented. Ain't I a stinker.")
    }
    
    // MARK: IBActions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        stopPlaying()
        AudioKit.stop()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tutorialButtonPressed(sender: AnyObject) {
        stopPlaying()
        performSegueWithIdentifier("tutorialSegue", sender: self)
    }
    
}

// MARK: - Table View Delegate

extension RecordingsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! RecordingCell
            let recording = Recording()
            do {
                try recording.deleteRecording(id: cell.id)
                tableView.reloadData()
                stopPlaying()
            } catch {
                Log.warning?.message("Recording couldn't be deleted. ID = \(cell.id)")
                let alert = UIAlertController(title: "Oh oh...", message: "Something went wrong, and your recording couldn't be deleted. If this issue persists, you might need to delete and reinstall the app. Sorry about that.", preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                alert.addAction(okButton)
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Whenever a row is selected, act like "play" was pressed on it if audio is playing.
        if currentlyPlaying {
            stopPlaying()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

// MARK: - Table View Data Source

extension RecordingsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let recording = Recording()
        return recording.getOrderedRecordingIDs().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let recording = Recording()
        let id = recording.getOrderedRecordingIDs()[indexPath.row]
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
