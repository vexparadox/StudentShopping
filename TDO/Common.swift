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