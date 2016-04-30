//
//  TutorialViewController.swift
//  Shh
//
//  Created by Matt Lebl on 2016-04-30.
//  Copyright © 2016 Matt Lebl. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var introText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        introText.text = "Speech Jammer is a great way to have fun with friends. It plays back whatever you say into the mic back to your ears, at a delay. This can make it virtually impossible to speak normally. Plug in your headphones, press the microphone icon, and start speaking! Speech Jammer is most effective with long sentences and stories, not with short phrases. You can also adjust the feedback delay. For native speakers, the most effective delay is 200 milliseconds. For non-native speakers, a longer delay works better."
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func goButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
