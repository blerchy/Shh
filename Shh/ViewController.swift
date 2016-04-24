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
    
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var buttonBackgroundView: UIView!
    @IBOutlet weak var recordSwitch: UISwitch!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var delaySlider: UISlider!
    @IBOutlet weak var delayLabel: UILabel!
    
    var microphone = AKMicrophone()
    var delay: AKVariableDelay?
    var jamming = false
    var timer = NSTimer()
    var tracker: AKAmplitudeTracker?
    var lastAmplitudes: [Double] = [0.0,0.0,0.0]
    var currentAmplitudeIndex = 0
    var greatestAmplitude: Double = 0.0
    var currentDelay: Double = 0.2
    
    let redColour = UIColor(red: 238, green: 108, blue: 77, alpha: 1)
    let whiteColour = UIColor(red: 224, green: 251, blue: 252, alpha: 1)
    let lowestDelay: Double = 0.05
    let highestDelay: Double = 2.0
    
    // MARK: UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        tracker = AKAmplitudeTracker(microphone)
        delay = AKVariableDelay(tracker!, time: 0.2, feedback: 0, maximumDelayTime: highestDelay)
        AudioKit.output = delay!
        AKSettings.audioInputEnabled = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05,
                                                       target: self,
                                                       selector: #selector(ViewController.measureAmplitude),
                                                       userInfo: nil,
                                                       repeats: true)
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
        dehighlightButton()
        if jamming {
            microphone.stop()
            resetAmplitudeValues()
            setInactiveColours()
        } else {
            microphone.start()
            setActiveColours()
            delay!.time = currentDelay
        }
        jamming = !jamming
    }
    
    @IBAction func buttonDown(sender: AnyObject) {
        highlightButton()
    }
    @IBAction func buttonExit(sender: AnyObject) {
        dehighlightButton()
    }
    @IBAction func buttonEnter(sender: AnyObject) {
        highlightButton()
    }
    
    @IBAction func sliderValueChanged(sender: AnyObject) {
        let slider = sender as! UISlider
        let delay = (Double(highestDelay - lowestDelay) * Double(slider.value)) + lowestDelay // THESE AREN'T AKOPERATIONS!!! :'(
        self.delay!.time = delay
        
        if delay < 1.0 {
            let userFriendyDelay = Double(round(delay * 10) * 100)
            delayLabel.text = "\(userFriendyDelay) MILLISECONDS"
        } else {
            let userFriendlyDelay = Double(round(delay * 10) / 10)
            delayLabel.text = "\(userFriendlyDelay) SECONDS"
        }
    }
    
    // MARK: Helper functions
    
    private func highlightButton() {
        let transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7)
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
            
                self.buttonBackgroundView.transform = transform
            
            }, completion: nil)
    }
    
    private func dehighlightButton() {
        let transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: { 
            
                self.buttonBackgroundView.transform = transform
            
            }, completion: nil)
    }
    
    private func setActiveColours() {
        UIView.animateWithDuration(0.2) {
            self.buttonBackgroundView.backgroundColor = self.redColour
        }
    }
    
    private func setInactiveColours() {
        UIView.animateWithDuration(0.2) {
            self.buttonBackgroundView.backgroundColor = self.whiteColour
        }
    }
    
    private func setupViews() {
        buttonBackgroundView.layer.cornerRadius = buttonBackgroundView.bounds.width / 2
        toggleButton.tintColor = redColour
    }
    
    private func resetAmplitudeValues() {
        lastAmplitudes = [0.0,0.0,0.0]
        currentAmplitudeIndex = 0
        greatestAmplitude = 0.0
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
            
            updateButtonBackground(value / greatestAmplitude)
            
            currentAmplitudeIndex += 1
            
            if currentAmplitudeIndex >= 3 {
                currentAmplitudeIndex = 0
            }
        }
    }
    
    func updateButtonBackground(amplitude: Double) {
        
        let transform = CGAffineTransformScale(CGAffineTransformIdentity,
                                               CGFloat((amplitude / 1.3) + 0.6),
                                               CGFloat((amplitude / 1.3) + 0.6))
        
        UIView.animateWithDuration(0.05, delay: 0, options: .CurveLinear, animations: {
            self.buttonBackgroundView.transform = transform
            }, completion: nil)
        
    }

}

