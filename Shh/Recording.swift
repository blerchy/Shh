//
//  Recording.swift
//  Shh
//
//  Created by Matt Lebl on 2016-04-21.
//  Copyright © 2016 Matt Lebl. All rights reserved.
//

import Foundation

class Recording {
    
    let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let fileManager = NSFileManager.defaultManager()
    
    // MARK: Class functions
    
    init() {
        print(documents)
    }
    
    /**
     Creates a new file and returns the ID
     
     - returns:
     The ID of the new file, which is also the filename (+ the wav extension)
     */
    func newFile() -> String {
        let id = randomAlphaNumericString(6)
        let fileName = "\(id).wav"
        
        if fileManager.fileExistsAtPath((documents as NSString).stringByAppendingPathComponent(fileName)) {
            return newFile() // wow recursion
        } else {
            fileManager.createFileAtPath((documents as NSString).stringByAppendingPathComponent(fileName), contents: NSData(), attributes: nil)
            
            // Add entry to recordings dictionary
            let recordings = getRecordingsDictionary()
            let dict = NSMutableDictionary()
            
            dict.setObject("New Recording", forKey: "name")
            dict.setObject(NSDate().timeIntervalSince1970, forKey: "time")
            
            recordings.setObject(NSDictionary(dictionary: dict), forKey: id)
            saveRecordingsDictionary(recordings)
            
            return id
        }
    }
    
    func renameRecording(id id: String, newName: String) {
        let recordings = getRecordingsDictionary()
        
        if let dict = recordings.objectForKey(id) as? NSMutableDictionary {
            dict.setObject(newName, forKey: "name")
            recordings.setObject(dict, forKey: id)
            saveRecordingsDictionary(recordings)
        }
    }
    
    func getRecordingIDs() -> [String] {
        return getRecordingsDictionary().allKeys as! [String]
    }
    
    func getInfoOnID(id id: String) -> (name: String, time: Double)? {
        let recordings = getRecordingsDictionary()
        let dict = recordings.objectForKey(id)
        
        if let name = dict?.objectForKey("name") {
            if let time = dict?.objectForKey("time") {
                return (name: name as! String, time: time as! Double)
            }
        }
        
        return nil
    }
    
    func deleteRecording(id id: String) throws {
        try fileManager.removeItemAtPath(getDocumentsPath().stringByAppendingPathComponent("\(id).wav"))
        let recordings = getRecordingsDictionary()
        recordings.removeObjectForKey(id)
        saveRecordingsDictionary(recordings)
    }
    
    func getDocumentsPath() -> NSString {
        return (documents as NSString)
    }
    
    // MARK: Helper Functions
    
    private func getRecordingsDictionary() -> NSMutableDictionary {
        return NSMutableDictionary(contentsOfFile: getRecordingsPlistPath() as String)!
    }
    
    private func saveRecordingsDictionary(dict: NSMutableDictionary) {
        dict.writeToFile(getRecordingsPlistPath() as String, atomically: true)
    }
    
    private func getRecordingsPlistPath() -> NSString {
        let path = (documents as NSString).stringByAppendingPathComponent("Recordings.plist")
        
        // If the file doesn't exist, copy it over from the bundle.
        if !fileManager.fileExistsAtPath(path) {
            let bundle = NSBundle.mainBundle().pathForResource("Recordings", ofType: "plist")
            try! fileManager.copyItemAtPath(bundle!, toPath: path)
        }
        
        return path
    }
    
    private func randomAlphaNumericString(length: Int) -> String {
        // Thanks http://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
        
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
}
