//
//  RecordingsViewController.swift
//  Shh
//
//  Created by Matt Lebl on 2016-04-26.
//  Copyright © 2016 Matt Lebl. All rights reserved.
//

import UIKit

// MARK: RecordingsViewController

class RecordingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
        let recordingInfo = recording.getInfoOnID(id: recording.getRecordingIDs()[indexPath.row])
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        cell.textLabel!.text = recordingInfo?.name
        
        // This is a train wreck
        cell.detailTextLabel!.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: NSTimeInterval((recordingInfo?.time)!)))
        
        return cell
    }
    
}