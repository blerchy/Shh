//
//  RecordingCell.swift
//  Shh
//
//  Created by Matt Lebl on 2016-04-26.
//  Copyright © 2016 Matt Lebl. All rights reserved.
//

import UIKit

class RecordingCell: UITableViewCell {
    
    var id = ""
    var delegate: RecordingsViewController?
    var playing = false
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playButtonPressed(sender: AnyObject) {
        if playing {
            delegate?.stopPlaying()
            playing = false
        } else {
            delegate?.playRecording(id: id)
            playing = true
        }
    }
    
}
