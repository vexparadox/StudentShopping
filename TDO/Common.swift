//
//  Common.swift
//  TDO
//
//  Created by William Meaton on 05/04/2016.
//  Copyright © 2016 William Meaton. All rights reserved.
//

import Foundation
//http://blog.appliedinformaticsinc.com/swift-sha256-ios-10-minute-quick-hack/
func sha256(data : NSData) -> String {
    let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))
    CC_SHA256(data.bytes, CC_LONG(data.length), UnsafeMutablePointer(res!.mutableBytes))
    return "\(res!)".stringByReplacingOccurrencesOfString("", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
}
//http://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
func randomAlphaNumericString(length: Int) -> String {
    
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

//salts and hashes a password
func saltHash(password: String, salt: String) -> String{
    var newPassword = password+salt
    newPassword = sha256(newPassword.dataUsingEncoding(NSUTF8StringEncoding)!) //hash it
    //remove the <>
    newPassword = newPassword.stringByReplacingOccurrencesOfString("<", withString: "")
    newPassword = newPassword.stringByReplacingOccurrencesOfString(">", withString: "")
    return newPassword
}