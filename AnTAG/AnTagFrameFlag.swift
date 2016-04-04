//
//  AnTagFrameOffset.swift
//  AnTagSample
//
//  Created by Younguk Wi on 3/9/16.
//  Copyright © 2016 ANightInSeoul. All rights reserved.
//

import Foundation

class AnTagFrameFlag {
    
    /* frame */
    var flagFrame: UInt8 = 0
    
    /* %abchkmnp */
    
    var tagPreservation: Bool {
        return (flagFrame & 0x80) != 0
    }
    
    var filePreservation: Bool { // b
        return (flagFrame & 0x40) != 0
    }
    var readOnly: Bool { // c
        return (flagFrame & 0x20) != 0
    }
    var isGroupID: Bool { // h
        return (flagFrame & 0x10) != 0
    }
    var isCompression: Bool { // k
        return (flagFrame & 0x08) != 0
    }
    var isEncryption: Bool { // m
        return (flagFrame & 0x04) != 0
    }
    var isUnsync: Bool { // n
        return (flagFrame & 0x02) != 0
    }
    var isDataLength: Bool { // p
        return (flagFrame & 0x01) != 0
    }
    
    let version: Int
    var groupID: Int = 0
    var dataLength: Int = 0
    var addedBytes: Int = 0
    
    var decompSize: Int = 0
    var encryptionMethod: Int = 0
    
    init?(data: Bytes, version: Int) {
        self.version = version
        
        if self.version == 3 || self.version == 4 {
            decodeFrameFlag(data)
        } else {
            return nil
        }
    }
    
    func decodeFrameFlag(data: Bytes) {
        
        let addedData = data + 2
        if version == 3 {
            flagFrame = data[0] & 0xE0
            flagFrame |= data[1] & 0xE0
            
            compression(addedData)
            encryption(addedData)
            getGroupID(addedData)
            
        } else {
            flagFrame = data[0] & 0x70
            flagFrame |= data[1] & 0x4F
            
            getGroupID(addedData)
            compression(addedData)
            encryption(addedData)
            getDataLength(addedData)
        }
    }
    
    func getGroupID(data: Bytes) {
        if isGroupID {
            groupID = Int(data[addedBytes++])
        }
    }
    
    func compression(data: Bytes) {
        if isCompression && version == 3 {
            decompSize = AnTagParser.getNormalSize(data + addedBytes)
            addedBytes += 4
        }
    }
    
    func encryption(data: Bytes) {
        if isEncryption {
            encryptionMethod = Int(data[addedBytes++])
        }
    }
    
    func getDataLength(data: Bytes) {
        if isDataLength {
            dataLength = AnTagParser.frameSize(data + addedBytes, version: version)
            addedBytes += 4
        }
    }

}