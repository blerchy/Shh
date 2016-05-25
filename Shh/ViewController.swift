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
    var recorder: AKAudioRecorder?
    var lastAmplitudes: [Double] = [0.0, 0.0, 0.0]
    var currentAmplitudeIndex = 0
    var greatestAmplitude: Double = 0.0
    var currentDelay: Double = 0.2
    var canRecord = true
    var lastRecordingID = ""
    
    let redColour = UIColor(red: 238/255, green: 108/255, blue: 77/255, alpha: 1)
    let whiteColour = UIColor(red: 224/255, green: 251/255, blue: 252/255, alpha: 1)
    let lowestDelay: Double = 0.05
    let highestDelay: Double = 2.0
    
    // MARK: UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        if !showTutorial() {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.05,
                                                           target: self,
                                                           selector: #selector(ViewController.measureAmplitude),
                                                           userInfo: nil,
                                                           repeats: true)
            tracker = AKAmplitudeTracker(microphone)
            delay = AKVariableDelay(tracker!, time: 0.2, feedback: 0, maximumDelayTime: highestDelay)
            AudioKit.output = delay!
            AKSettings.audioInputEnabled = true
            AKSettings.defaultToSpeaker = true
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
            
            showTestingIncentive()
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
                alert.addTextFieldWithConfigurationHandler { textField in
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
        if let slider = sender as? UISlider {
            let delay = (Double(highestDelay - lowestDelay) * Double(slider.value)) + lowestDelay // THESE AREN'T AKOPERATIONS!!! :'(
            self.delay!.time = delay

            let roundedDelay = Int(round(delay * 10))

            delayLabel.textColor = whiteColour
            delayLabel.alpha = 0.4

            if roundedDelay < 10 {
                delayLabel.text = "\(roundedDelay * 100) MILLISECONDS"

                if roundedDelay * 100 == 200 {
                    delayLabel.textColor = redColour
                    delayLabel.alpha = 1
                }

            } else {
                delayLabel.text = "\(Double(Double(roundedDelay) / 10)) SECONDS"
            }
        }
    }
    
    @IBAction func showRecordings(sender: AnyObject) {
        AudioKit.stop()
        performSegueWithIdentifier("recordingsSegue", sender: self)
    }
    
    // MARK: Helper functions
    
    private func showTestingIncentive() {
        let alert = UIAlertController(title: "Thanks for Testing!", message: "I wanted to thank you for taking the time to test my app. As a small incentive, I wanted to offer you any $5 gift card of your choice if you discover any bugs or unexpected behaviour. I want you to know how much I appreciate your time and effort. Also, if you find a crash or other serious bug which stops you dead in your tracks, I'll make it $10. Happy hunting!", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func showTutorial() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let key = "tutorialShown"
        if !defaults.boolForKey(key) {
            print("Showing tutorial")
            
            defaults.setBool(true, forKey: key)
            performSegueWithIdentifier("tutorialSegue", sender: self)
            return true
        } else {
            print("Not showing tutorial")
            return false
        }
    }
    
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
            self.toggleButton.tintColor = self.whiteColour
        }
    }
    
    private func setInactiveColours() {
        UIView.animateWithDuration(0.2) {
            self.buttonBackgroundView.backgroundColor = self.whiteColour
            self.toggleButton.tintColor = self.redColour
        }
    }
    
    private func setupViews() {
        // Make the button background circle shaped, rather than a square
        buttonBackgroundView.layer.cornerRadius = buttonBackgroundView.bounds.width / 2
        
        // Change the button image to a template, so it reflects the tint colour
        let image = UIImage(named: "mic")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        toggleButton.setImage(image, forState: .Normal)
        toggleButton.tintColor = redColour
    }
    
    private func resetAmplitudeValues() {
        lastAmplitudes = [0.0, 0.0, 0.0]
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
