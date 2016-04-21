//
//  ViewController.swift
//  Shh
//
//  Created by Matt Lebl on 2016-04-18.
//  Copyright © 2016 Matt Lebl. All rights reserved.
//

// Colour scheme: https://coolors.co/app/3d5a80-98c1d9-e0fbfc-ee6c4d-293241

import UIKit
import AudioKit

class ViewController: UIViewController {
    
    @IBOutlet weak var buttonBackgroundView: UIView!
    @IBOutlet weak var recordSwitch: UISwitch!
    @IBOutlet weak var recordLabel: UILabel!
    
    var microphone = AKMicrophone()
    var delay: AKDelay?
    var jamming = false
    var timer = NSTimer()
    var tracker: AKAmplitudeTracker?
    var lastAmplitudes: [Double] = [0.0,0.0,0.0]
    var currentAmplitudeIndex = 0
    var greatestAmplitude: Double = 0.0
    
    // MARK: UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        tracker = AKAmplitudeTracker(microphone)
    }
    
    override func viewDidAppear(animated: Bool) {
//        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(ViewController.measureAmplitude), userInfo: nil, repeats: true)
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
    
    // MARK: IBActions

    @IBAction func toggleJammer(sender: AnyObject) {
        if jamming {
            microphone.stop()
            resetAmplitudeValues()
        } else {
            microphone.start()
        }
        jamming = !jamming
    }
    
    @IBAction func buttonDown(sender: AnyObject) {
        
    }
    @IBAction func buttonExit(sender: AnyObject) {
        
    }
    @IBAction func buttonEnter(sender: AnyObject) {
        
    }
    
    // MARK: Helper functions
    
    func setupViews() {
        buttonBackgroundView.layer.cornerRadius = buttonBackgroundView.bounds.width / 2
    }
    
    func resetAmplitudeValues() {
        lastAmplitudes = [0.0,0.0,0.0]
        currentAmplitudeIndex = 0
        greatestAmplitude = 0.0
    }
    
//    func measureAmplitude() {
//        if jamming {
//            lastAmplitudes[currentAmplitudeIndex] = tracker!.amplitude
//            var value: Double = 0.0
//            for amplitude in lastAmplitudes {
//                value += amplitude
//            }
//            value = value / 3
//            if value > greatestAmplitude {
//                greatestAmplitude = value
//            }
//            currentAmplitudeIndex += 1
//            if currentAmplitudeIndex >= 3 {
//                currentAmplitudeIndex = 0
//            }
//            
//            amplitudeIndicator.setProgress(Float(value / greatestAmplitude), animated: true)
//            
//            currentAmplitudeIndex += 1
//            
//            if currentAmplitudeIndex >= 3 {
//                currentAmplitudeIndex = 0
//            }
//        }
//    }

}

