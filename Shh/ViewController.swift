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
    
    var microphone = AKMicrophone()
    var delay: AKDelay?
    var jamming = false
    var timer = NSTimer()
    var tracker: AKAmplitudeTracker?
    var recorder: AKAudioRecorder?
    var lastAmplitudes: [Double] = [0.0,0.0,0.0]
    var currentAmplitudeIndex = 0
    var greatestAmplitude: Double = 0.0
    var canRecord = true
    var lastRecordingID = ""
    
    let redColour = UIColor(red: 238, green: 108, blue: 77, alpha: 1)
    let whiteColour = UIColor(red: 224, green: 251, blue: 252, alpha: 1)
    
    // MARK: UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
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
        tracker = AKAmplitudeTracker(microphone)
        delay = AKDelay(tracker!, time: 0.2, dryWetMix: 1.0, feedback: 0)
        AudioKit.output = delay!
        AKSettings.audioInputEnabled = true
        AudioKit.start()
        microphone.stop()
        tracker?.start()
        
        // Try to set the input device to the microphone, disable recording if it couldn't.
        do {
            try AudioKit.setInputDevice(AudioKit.availableInputs!.first!)
        } catch {
            canRecord = false
            recordSwitch.enabled = false
            print("Caught!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions

    @IBAction func toggleJammer(sender: AnyObject) {
        dehighlightButton()
        if jamming {
            // If recording is enabled, enable the switch.
            recordSwitch.enabled = canRecord
            
            if recordSwitch.on {
                recorder!.stop()
                let alert = UIAlertController(title: "Title Your Recording", message: nil, preferredStyle: .Alert)
                let action = UIAlertAction(title: "Okay", style: .Default) { _ in
                    if let field = alert.textFields?[0] {
                        let recording = Recording()
                        
                        // Renames the last recording. If the text field is blank, it'll be renamed to "New Recording" instead.
                        recording.renameRecording(id: self.lastRecordingID, newName: field.text! != "" ? field.text! : "New Recording")
                    }
                }
                
                // Add text field to alert
                alert.addTextFieldWithConfigurationHandler() { textField in
                    textField.placeholder = "New Recording"
                }
                
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            microphone.stop()
            resetAmplitudeValues()
            setInactiveColours()
        } else {
            recordSwitch.enabled = false
            
            if recordSwitch.on {
                let recording = Recording()
                let id = recording.newFile()
                recorder = AKAudioRecorder(recording.getDocumentsPath().stringByAppendingPathComponent("\(id).wav"))
                lastRecordingID = id
                recorder!.record()
            }
            
            microphone.start()
            setActiveColours()
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
    
    @IBAction func showRecordings(sender: AnyObject) {
        AudioKit.stop()
        performSegueWithIdentifier("recordingsSegue", sender: self)
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

