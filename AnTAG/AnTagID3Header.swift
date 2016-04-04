//
//  AnTagID3Header.swift
//  AnTagSample
//
//  Created by Younguk Wi on 3/9/16.
//  Copyright © 2016 ANightInSeoul. All rights reserved.
//

import Foundation

typealias Bytes = UnsafePointer<UInt8>

class AnTagID3Header {
    
    var headerFrame: [UInt8]

    var readFrameSize: Int = 0
    var version: Int = 0
    var unSyncFlag: Bool = false
    var hasExtendedHeader: Bool = false
    var experimentalIndicator: Bool = false
    var footerPresent: Bool = false
    
    var extendedHeader: AnyObject?
    
    
    
    init?(data: Bytes) {
        headerFrame = [UInt8](count: AnTagFile.HEADER_SIZE, repeatedValue: 0x00)
        
        for var i = 0 ; i < AnTagFile.HEADER_SIZE; i++ {
            headerFrame[i] = data[i]
        }
        
        readFrameSize = AnTagParser.iD3v2Size(data)
        version = AnTagParser.subVersion(data)!.0
        
        if version != 3 && version != 4 {
            print("Not support Version")
            
            return nil
            
        } else {
            
            unSyncFlag = AnTagParser.isUnsync(data)
            hasExtendedHeader = AnTagParser.isExtendedHeader(data)
            experimentalIndicator = AnTagParser.isExperimental(data)
            footerPresent = AnTagParser.isFooterPresent(data)
            
            if hasExtendedHeader {
                print("!!!!!!!!! has Extended Header")
            }
        }
    }
    
    
    
}