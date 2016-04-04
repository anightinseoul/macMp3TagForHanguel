//
//  FrameID.swift
//  AnMP3 Editer
//
//  Created by Younguk Wi on 2/19/16.
//  Copyright © 2016 ANightInSeoul. All rights reserved.
//

import Foundation

struct FrameID {
    
    typealias Byte = UInt8
    typealias Bytes = UnsafePointer<UInt8>
    
    static let TITLE: [Byte] = [0x54, 0x49, 0x54, 0x32] //TIT2
    static let TRACK: [Byte] = [0x54, 0x52, 0x43, 0x4B] //TRCK
    static let YEAR: [Byte] = [0x54, 0x59, 0x45, 0x52] //TYER
    static let ALBUM: [Byte] = [0x54, 0x41, 0x4C, 0x42] // TALB
    static let SORT_ALBUM: [Byte] = [0x54, 0x53, 0x4F, 0x41] // TSOL
    static let ENCODED: [Byte] = [0x54, 0x45, 0x4E, 0x43] //TENC
    static let PERFORMER: [Byte] = [0x54, 0x50, 0x45, 0x31] //TPE1
    static let BAND: [Byte] = [0x54, 0x50, 0x45, 0x32] //TPE2
    static let PART: [Byte] = [0x54, 0x50, 0x4F, 0x53] //TPOS
    static let TYPE: [Byte] = [0x54, 0x43, 0x4F, 0x4E] //TCON
    static let COPY: [Byte] = [0x54, 0x43, 0x4F, 0x50] //TCOP
    
    static let PIC: [Byte] = [0x41, 0x50, 0x49, 0x43] //APIC
    static let COMM : [Byte] = [0x43, 0x4F, 0x4D, 0x4D] //COMM
    static let UURL : [Byte] = [0x57, 0x58, 0x58, 0x58] //WXXX
    static let LYRIC: [Byte] = [0x55, 0x53, 0x4C, 0x54] //USLT
    static let PRIVATE: [Byte] = [0x50, 0x52, 0x49, 0x56] // PRIV
    
    static let PADDING: [Byte] = [0x00, 0x00, 0x00]

    static let IDArray: [[Byte]] = [
        TITLE,
        TRACK,
        YEAR,
        ALBUM,
        SORT_ALBUM,
        LYRIC,
        PERFORMER,
        BAND,
        PART,
        TYPE,
        COPY,
        PIC,
        COMM,
        UURL,
        ENCODED,
        PRIVATE
    ]
    
    enum FrameIDType: Int {
        case TITLE,
        TRACK,
        YEAR,
        ALBUM,
        SORT_ALBUM,
        LYRIC,
        PERFORMER,
        BAND,
        PART,
        TYPE,
        COPY,
        PIC,
        COMM,
        UURL,
        ENCODED,
        PRIVATE
    }
}
