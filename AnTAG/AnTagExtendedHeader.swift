//
//  AnTagExtendedHeader.swift
//  AnTagSample
//
//  Created by Younguk Wi on 3/9/16.
//  Copyright © 2016 ANightInSeoul. All rights reserved.
//

import Foundation

class AnTagExtendedHeader {
    
    
    // common elements
    var size: Int = 0
    var hasCrcData: Bool = false
    var crcValue: Int = 0
    
    // v4 options
    let flagBytes: Int = 1
    
    var isUpdate: Bool = false
    let updateSize: Int = 1
    
    let crcSize: Int = 5
    
    var hasRestriction: Bool = false
    let restrictionSize: Int = 1
    
    
    // v3 options
    var sizeofPadding: Int = 0

    init(data: Bytes, version: Int) {
        
    }
}