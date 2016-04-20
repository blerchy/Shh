//
//  ViewController.swift
//  Shh
//
//  Created by Matt Lebl on 2016-04-18.
//  Copyright © 2016 Matt Lebl. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    @IBOutlet weak var amplitudeIndicator: UIProgressView!
    
    var microphone = AKMicrophone()
    var delay: AKDelay?
    var jamming = false
    var timer = NSTimer()
    var tracker: AKAmplitudeTracker?
    var lastAmplitudes: [Double] = [0.0,0.0,0.0]
    var currentAmplitudeIndex = 0
    var greatestAmplitude: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        amplitudeIndicator.progress = 0
        tracker = AKAmplitudeTracker(microphone)
    }
    
    override func viewDidAppear(animated: Bool) {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(ViewController.measureAmplitude), userInfo: nil, repeats: true)
        delay = AKDelay(tracker!, time: 0.2, dryWetMix: 1.0, feedback: 0)
        AudioKit.output = tracker!
        AKSettings.audioInputEnabled = true
        AudioKit.start()
        microphone.stop()
        tracker?.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleJammer(sender: AnyObject) {
        let button = sender as! UIButton
        if jamming {
            microphone.stop()
            button.setTitle("Start Jamming", forState: .Normal)
            resetAmplitudeValues()
        } else {
            microphone.start()
            button.setTitle("Stop Jamming", forState: .Normal)
        }
        jamming = !jamming
    }
    
    func resetAmplitudeValues() {
        lastAmplitudes = [0.0,0.0,0.0]
        currentAmplitudeIndex = 0
        greatestAmplitude = 0.0
        amplitudeIndicator.progress = 0
    }
    
    func measureAmplitude() {
        if jamming {
            lastAmplitudes[currentAmplitudeIndex] = tracker!.amplitude
            var value: Double = 0.0
            for amplitude in lastAmplitudes {
                value += amplitude
            }
            value = value / 3
            if value > greatestAmplitude {
                greatestAmplitude = value
            }
            currentAmplitudeIndex += 1
            if currentAmplitudeIndex >= 3 {
                currentAmplitudeIndex = 0
            }
            amplitudeIndicator.progress = Float(value / greatestAmplitude)
        }
    }

}

