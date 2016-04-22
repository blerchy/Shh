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
            
            return id
        }
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
