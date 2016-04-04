//
//  AnTagParser.swift
//  AnMP3 Editer
//
//  Created by Younguk Wi on 2/22/16.
//  Copyright © 2016 ANightInSeoul. All rights reserved.
//

import Foundation

class AnTagParser {
    

    typealias Bytes = UnsafePointer<UInt8>
    
    static let HEADER_OFFSET = 10
    static let EXTENDED_HEADER_OFFSET = 6
    static let FRAME_ID_OFFSET = 4
    static let FRAME_ENCODING_OFFSET = 1
    static let FRAME_SIZE_OFFSET = 4
    static let FRAME_FLAG_OFFSET = 2
    
    enum TagErrorType: ErrorType {
        case ExtendedHeaderSizeError
        case NotSupportedError
    }
    
    enum FrameStructType: Int {
        case EnCodedText
        case Text
        case AttachedPicture
        case Comment
        case UserDefinedURL
    }
    
    enum EncodingType {
        case ISO88591
        case UTF16
        case UTF16BE
        case UTF8
    }
    
    enum PictureType: Int {
        
        case OTHER = 0
        case FILE_ICON = 1
        case OTHER_FILE_ICON = 2
        case FRONT_COVER = 3
        case BACK_COVER = 4
        case LEAFLET_PAGE = 5
        case MEDIA = 6
        case LEAD_ARTIST = 7
        case ARITEST = 8
        case CONDUCTOR = 9
        case BAND = 10
        case COMPOSER = 11
        case LYRICIST = 12
        case RECORDING_LOC = 13
        case DURING_RECORDING = 14
        case DURING_PERFORMANCE = 15
        case MOVIE_CAPTURE = 16
        case BRIGHT_COLOURED_FISH = 17
        case ILLUSTRATION = 18
        case BAND_LOGOTYPE = 19
        case PUBLISHER_LOGOTYPE = 20
        
    }
    
    static let Genre: [String] = [
        "Alternative",
        "Ballad",
        "Blues/R&B",
        "Books & Spoken",
        "Children's Music",
        "Classical",
        "Country",
        "Dance",
        "Drama",
        "Easy Listening",
        "Electronic",
        "Folk",
        "Hip Hop/Rap",
        "Hip-Hop/Rap",
        "Holiday",
        "House",
        "Industrial",
        "Jazz",
        "New Age",
        "Podcast",
        "Rap / Hip-hop",
        "Religious",
        "Rock",
        "Singer/Songwriter",
        "Soundtrack",
        "Techno",
        "Trance",
        "Unclassifiable",
        "World" ]
    
    
    class func isID3v2Tag(data: Bytes) -> Bool {
        if data[0] == 0x49 && data[1] == 0x44 && data[2] == 0x33 {
            return true
        }
        return false
    }
    
    class func setID3v2Tag(inout data: [UInt8]) {
        data[0] = 0x49
        data[1] = 0x44
        data[2] = 0x33
    }

    class func subVersion(data: Bytes) -> (Int, Int)? {
        if data[3] != 0xFF && data[4] != 0xFF {
            return (Int(data[3]), Int(data[4]))
        }
        return nil
    }
    
    class func isUnsync(data: Bytes) -> Bool {
        if (data[5] & 0x80) != 0 {
            return true
        }
        return false
    }
    
    class func isExtendedHeader(data: Bytes) -> Bool {
        if (data[5] & 0x40) != 0 {
            return true
        }
        return false
    }
    
    class func isExperimental(data: Bytes) -> Bool {
        if (data[5] & 0x20) != 0 {
            return true
        }
        return false
    }
    
    class func isFooterPresent(data: Bytes) -> Bool {
        if (data[5] & 0x10) != 0 {
            return true
        }
        return false
    }
    
    class func isFlagVaild(data: Bytes) -> Bool {
        if (data[5] & 0x0F) == 0 {
            return true
        }
        return false
    }
    
    class func getSyncsafeSize(data: Bytes) -> Int {
        
        let offset = 7
        var shift = 21
        var result = 0
        
        for i in 0...3 {
            result += Int(data[i]) << shift
            shift -= offset
        }
        
        return result
    }
    
    class func getNormalSize(data: Bytes) -> Int {
        let offset = 8
        var shift = 24
        var result = 0
        
        for i in 0...3 {
            result += Int(data[i]) << shift
            shift -= offset
        }
        
        return result
    }
    
    class func generateSize(length: Int, version: Int) -> [UInt8] {
        var offset: Int
        var shift: Int
        var temp = length
        var result: [UInt8] = [0x0, 0x0, 0x0, 0x0]
        
        if version == 3 { // generate Normal size
            offset = 8
            shift = 24
        } else if version == 4 { // generate safesync size
            offset = 7
            shift = 21
        } else {
            print("Not supported Version")
            return result
        }
        
        result[0] = UInt8(temp >> shift)

        for i in 1...3 {
            let sub = Int(result[i - 1]) << shift
            shift -= offset
            temp -= sub
            
            result[i] = UInt8(temp >> shift)
        }
        
        return result
    }
    
    class func iD3v2Size(data: Bytes) -> Int {
        /* 6, 7, 8, 9 (syncsafe integer) 4bytes */
        let byte = data + 6
        
        return getSyncsafeSize(byte)
    }
    
    class func extendedHeaderSize(data: Bytes) -> Int {
        let byte = data + HEADER_OFFSET
        
        let size = getSyncsafeSize(byte)
        /*
        if size < 6 {
        throw TagErrorType.ExtendedHeaderSizeError
        }*/
        
        return size
    }
    
    class func numberOfFlagBytes(data: Bytes) -> Int {
        let byte = data + HEADER_OFFSET + 4
        
        return Int(byte[0])
    }
    
    class func extendedFlag(data: Bytes) throws {
        throw TagErrorType.NotSupportedError
    }
    
    class func encoding(data: Bytes) -> UInt {
        switch data[0] {
        case 0:
            return NSASCIIStringEncoding
        case 1:
            return NSUTF16StringEncoding
        case 2:
            return NSUTF16BigEndianStringEncoding
        case 3:
            return NSUTF8StringEncoding
        default:
            return NSASCIIStringEncoding
        }
    }
    
    class func revertEncoding(data: UInt) -> UInt8 {
        switch data {
        case NSASCIIStringEncoding:
            return 0
        case NSUTF16StringEncoding:
            return 1
        case NSUTF16BigEndianStringEncoding:
            return 2
        case NSUTF8StringEncoding:
            return 3
        default:
            return 3
        }
    }
    
    class func frameFormatFlag(data: Bytes) -> (unsync: Bool, length: Int) {
        // 0h00kmnp
        var unsync: Bool = false
        var length = 0
        if data[0] != 0 {
            if (data[0] & 0x01) != 0 { // Data length indicator
                unsync = true
            }
            
            if (data[0] & 0x02) != 0 { // Unsynchronisation
                length = AnTagParser.getSyncsafeSize(data + 1)
            }
        }
        
        return (unsync, length)
    }
    
    class func MIMEType(data: Bytes, inout Size size: Int) -> String {
        var i = 0
        var str : [UInt8] = []
        
        while data[i] != 0x00 {
            str.append(data[i++])
        }
        
        size = i + 1
        
        let result = NSString(bytes: str, length: i, encoding: NSASCIIStringEncoding) as String?
        
        if let result = result {
            return result
        } else {
            return "unknowun"
        }

        
//        return NSString(bytes: str, length: i, encoding: NSUTF8StringEncoding)! as String
    }
    
    class func description(data: Bytes, encoding: UInt, inout Size size: Int) -> String {
        
        var i = 0
        var str : [UInt8] = []
        
        let UNILCODE_NIL: [UInt8] = [0x00, 0x00]
        let NIL: UInt8 = 0x00
        
        if (encoding != NSASCIIStringEncoding) {
            
            // UNICODE's null value is 0x00 0x0
            var word = [data[i], data[i + 1]]
            
            while word != UNILCODE_NIL {
                str.append(word[0])
                str.append(word[1])
                
                i = i + 2
                word = [data[i], data[i + 1]]
            }
            size = i + 2
        } else {
            while data[i] != NIL {
                str.append(data[i++])
            }
            size = i + 1
        }
        
        return NSString(bytes: str, length: i, encoding: encoding)! as String
        
    }
    
    class func picType(data: Bytes) -> PictureType {
        
        let i = data[0]
        
        switch i {
        case 0:
            return .OTHER
        case 1:
            return .FILE_ICON
        case 3:
            return .FRONT_COVER
        default:
            return .OTHER
        }
    }
    
    class func skipFrame(data: Bytes, version: Int) -> Int {
        
        let frameSize = AnTagParser.frameSize(data + FRAME_ID_OFFSET, version: version)
        
        //print("frameSize : \(frameSize)")
        
        return frameSize + HEADER_OFFSET
    }
    
    class func frameHeader(data: Bytes, version: Int, inout frameBytes: Bytes, inout dataSize: Int, inout unSyncData: [UInt8]) -> Int {

        var offset = FRAME_ID_OFFSET
        
        let frameSize = AnTagParser.frameSize(data + offset, version: version)
        offset += FRAME_SIZE_OFFSET
        
        let flag = AnTagFrameFlag(data: data + offset, version: version)
        offset += FRAME_FLAG_OFFSET
        
        frameBytes = data + offset
        dataSize = frameSize
        
        if let flag = flag {
            if version == 4 {
                
                frameBytes += flag.addedBytes
                
                if (flag.isUnsync) {
                    unSyncData = [UInt8](count: frameSize, repeatedValue: 0x00)
                    dataSize = AnTagParser.unSynchro(frameBytes, to: &unSyncData, size: frameSize)
                    frameBytes = UnsafePointer<UInt8>(unSyncData)
                }
                
                if flag.isDataLength {
                    print(dataSize)
                    dataSize = flag.dataLength
                    print("after : \(dataSize)")
                }
            }
        }
        
        return frameSize
    }
    
    class func urlWithSize(data: Bytes, version: Int) -> (description: String, URL: String, readLength: Int) {
        
        var frameBytes: Bytes = nil
        var dataSize = 0
        var unSyncData: [UInt8] = []
        
        let frameSize = frameHeader(data, version: version, frameBytes: &frameBytes, dataSize: &dataSize, unSyncData: &unSyncData)
        
        let encoding = AnTagParser.encoding(frameBytes)
        frameBytes += FRAME_ENCODING_OFFSET
        
        var desSize = 0
        let description = AnTagParser.description(frameBytes, encoding: encoding, Size: &desSize)
        frameBytes += desSize
        
        let URL = NSString(bytes: frameBytes, length: dataSize - AnTagFile.FRAME_ENCODING_OFFSET - desSize, encoding: NSASCIIStringEncoding)! as String
        
        return (description, URL, frameSize + 10)

    }
    
    class func commWithSize(data: Bytes, version: Int) -> (lan: String?, shortDescription: String, comments: String, readLength: Int) {
        var frameBytes: Bytes = nil
        var dataSize = 0
        var unSyncData: [UInt8] = []
        
        let frameSize = frameHeader(data, version: version, frameBytes: &frameBytes, dataSize: &dataSize, unSyncData: &unSyncData)
        
        var encoding = AnTagParser.encoding(frameBytes)
        frameBytes += FRAME_ENCODING_OFFSET

        
        let lan = NSString(bytes: frameBytes, length: 3, encoding: NSASCIIStringEncoding) as String?
        frameBytes += 3
        
        var desSize = 0
        let shortDescription = AnTagParser.description(frameBytes, encoding: encoding, Size: &desSize)
        frameBytes += desSize
        
        if encoding == NSASCIIStringEncoding {
            encoding = CFStringConvertEncodingToNSStringEncoding( 0x0422 )
        }
        
        var comments = NSString(bytes: frameBytes, length: dataSize - AnTagFile.FRAME_ENCODING_OFFSET - 3 - desSize, encoding: encoding)
        if comments == nil {
            comments = NSString(bytes: frameBytes, length: dataSize - AnTagFile.FRAME_ENCODING_OFFSET - 3 - desSize, encoding: NSASCIIStringEncoding)
        }
        
        return (lan, shortDescription, comments! as String, frameSize + 10)

    }
    
    class func prictureWithSize(data: Bytes, version: Int) -> (MIMEType: String, picType: PictureType, picDescription: String, picImage: NSData, readLength: Int) {
        var frameBytes: Bytes = nil
        var dataSize = 0
        var unSyncData: [UInt8] = []
        
        let frameSize = frameHeader(data, version: version, frameBytes: &frameBytes, dataSize: &dataSize, unSyncData: &unSyncData)
        
        let encoding = AnTagParser.encoding(frameBytes)
        frameBytes += FRAME_ENCODING_OFFSET

        
        var MIMESize = 0
        let MIMEType = AnTagParser.MIMEType(frameBytes, Size: &MIMESize)
        frameBytes += MIMESize
        
        let picType = AnTagParser.picType(frameBytes)
        frameBytes += 1
        
        var desSize = 0
        let picDescription = AnTagParser.description(frameBytes, encoding: encoding, Size: &desSize)
        frameBytes += desSize
        
        let picImage = NSData(bytes: frameBytes, length: dataSize - AnTagFile.FRAME_ENCODING_OFFSET - MIMESize - desSize - 1)
        
        return (MIMEType, picType, picDescription, picImage, frameSize + 10)
        
        //picture = AnTagFile.Picture(MIMEType: MIMEType, picType: picType, picDescripion: picDescripion, picImage: picImage)
    }
    
    class func encodedStringWithSize(data: Bytes, version: Int) -> (encodedString: NSString, size: Int) {
        var frameBytes: Bytes = nil
        var dataSize = 0
        var unSyncData: [UInt8] = []
        
        let frameSize = frameHeader(data, version: version, frameBytes: &frameBytes, dataSize: &dataSize, unSyncData: &unSyncData)

        var encoding = AnTagParser.encoding(frameBytes)
        frameBytes += FRAME_ENCODING_OFFSET
        
        if encoding == NSASCIIStringEncoding {
            encoding = CFStringConvertEncodingToNSStringEncoding( 0x0422 )
        }

        var encodedString: NSString?
        
        
        encodedString = NSString(bytes: frameBytes, length: dataSize - AnTagFile.FRAME_ENCODING_OFFSET, encoding: encoding)
        if encodedString == nil {
            encodedString = NSString(bytes: frameBytes, length: dataSize - AnTagFile.FRAME_ENCODING_OFFSET, encoding: NSASCIIStringEncoding)
        }
        
        
        return (encodedString!, frameSize + 10)
    }
    
    class func writeTextFrame(inout writeFrame: [UInt8], text: String, frameSize: Int, version: Int, Index: Int, writeStringEncoding: UInt, unSyncFlag: Bool) {
        var i = Index
        let totalSize = frameSize + HEADER_OFFSET
        
        let size = AnTagParser.generateSize(frameSize, version: version)
        //print("\(size[0]), \(size[1]), \(size[2]), \(size[3])")
        
        for ; i < AnTagFile.FRAME_SIZE_OFFSET + AnTagFile.FRAME_ID_OFFSET; i++ {
            writeFrame[i] = size[i - AnTagFile.FRAME_ID_OFFSET]
        }
        
        // Flag set to zero
        writeFrame[i++] = 0x00
        writeFrame[i++] = 0x00
        
        // HEADER END //
        
        // Encoding Start
        writeFrame[i++] = AnTagParser.revertEncoding(writeStringEncoding)
        
        // Body
        let data = UnsafePointer<UInt8>(text.dataUsingEncoding(writeStringEncoding)!.bytes)
        
        for ; i < totalSize; i++ {
            writeFrame[i] = data[i - 11]
        }
    }
    
    class func writeCommentFrame(inout writeFrame: [UInt8], contents: AnTagFile.Comment, frameSize: Int, version: Int, Index: Int, writeStringEncoding: UInt) {

        let lanSize = 3
        var descriptionSize = 2
        let textSize = contents.comment.lengthOfBytesUsingEncoding(writeStringEncoding) + 2

        if let description = contents.shortDescription {
            descriptionSize += description.lengthOfBytesUsingEncoding(writeStringEncoding)
        }
        
        /*
        Text encoding           $xx
        Language                $xx xx xx
        Short content descrip.  <text string according to encoding> $00 (00)
        The actual text         <full text string according to encoding> */
        
        var i = Index
        // SIZE
        let sizeArray = AnTagParser.generateSize(frameSize, version: version)
        for var j = 0; j < 4; j++ {
            writeFrame[i++] = sizeArray[j]
        }
        
        // FLAG
        writeFrame[i++] = 0x00
        writeFrame[i++] = 0x00
        
        // Encoding
        writeFrame[i++] = AnTagParser.revertEncoding(writeStringEncoding)
        
        // Language
        if let language = contents.language {
            for var j = 0; j < lanSize; i++, j++ {
                let lan = UnsafePointer<UInt8>(language.dataUsingEncoding(NSASCIIStringEncoding)!.bytes)
                writeFrame[i] = lan[j]
            }
        } else {
            for var j = 0; j < lanSize; i++, j++ {
                writeFrame[i] = 0x00
            }
        }
        
        // Description
        if let description = contents.shortDescription {
            let des = UnsafePointer<UInt8>(description.dataUsingEncoding(writeStringEncoding)!.bytes)
            for var j = 0; j < descriptionSize - 2; i++, j++ {
                writeFrame[i] = des[j]
            }
        }
        writeFrame[i++] = 0x00
        writeFrame[i++] = 0x00
        
        // Text
        let commentText = UnsafePointer<UInt8>(contents.comment.dataUsingEncoding(writeStringEncoding)!.bytes)
        for var j = 0; j < textSize; i++, j++ {
            writeFrame[i] = commentText[j]
        }
        
        //print("Comment length : \(i), \(frameSize)")
    }
    
    class func unSynchro(from: Bytes, inout to: [UInt8], size: Int) -> Int {
        
        var readIndex = 0
        var writeIndex = 0
        
        for ; readIndex < size; readIndex++ {
            if from[readIndex] == 0xFF && from[readIndex + 1] == 0x00 {
                to[writeIndex++] = from[readIndex]
                readIndex++
            } else {
                to[writeIndex++] = from[readIndex]
            }
        }
        
        return writeIndex
    }
    
    class func synchro(from: [[UInt8]]?, inout to: [[UInt8]]) {
        
        if let from = from {
            
            for var i = 0; i < from.count; i++ {
                
                var frame: [UInt8] = []

                for var j = 0; j < from[i].count; j++ {

                    if from[i][j] == 0xFF {
                        frame.append(from[i][j])
                        frame.append(0x00)

                    } else {
                        frame.append(from[i][j])
                    }
                }
                to.append(frame)
            }
        }
    }
    
    class func isPerformer(frameID: Bytes) -> Bool {
        
        for i in 0...3 {
            if frameID[i] != FrameID.PERFORMER[i] {
                return false
            }
        }
        return true
    }
    
    class func isTitle(frameID: Bytes) -> Bool {
        
        for i in 0...3 {
            if frameID[i] != FrameID.TITLE[i] {
                return false
            }
        }
        return true
    }
    
    class func isTrack(frameID: Bytes) -> Bool {
        
        for i in 0...3 {
            if frameID[i] != FrameID.TRACK[i] {
                return false
            }
        }
        return true
    }
    
    class func isYear(frameID: Bytes) -> Bool {
        
        for i in 0...3 {
            if frameID[i] != FrameID.YEAR[i] {
                return false
            }
        }
        return true
    }
    
    class func isAlbum(frameID: Bytes) -> Bool {
        
        for i in 0...3 {
            if frameID[i] != FrameID.ALBUM[i] {
                return false
            }
        }
        return true
    }
    
    
    class func isLyric(frameID: Bytes) -> Bool {
        for i in 0...3 {
            if frameID[i] != FrameID.LYRIC[i] {
                return false
            }
        }
        return true
    }
    
    class func isPart(frameID: Bytes) -> Bool {
        for i in 0...3 {
            if frameID[i] != FrameID.PART[i] {
                return false
            }
        }
        return true
    }
    
    /* data's start offset ?? : (1) start of frame (2) start of Size */
    class func frameSize(data: Bytes, version: Int) -> Int {
        if version == 4 {
            return getSyncsafeSize(data)
        } else if version == 3 {
            return getNormalSize(data)
        } else {
            print("Not support Version")
            return -1
        }
    }
    
    class func isContentType(frameID: Bytes) -> Bool {
        for i in 0...3 {
            if frameID[i] != FrameID.TYPE[i] {
                return false
            }
        }
        return true
    }
    
    class func isBand(frameID: Bytes) -> Bool {
        for i in 0...3 {
            if frameID[i] != FrameID.BAND[i] {
                return false
            }
        }
        return true
    }
    
    class func isCopy(frameID: Bytes) -> Bool {
        for i in 0...3 {
            if frameID[i] != FrameID.COPY[i] {
                return false
            }
        }
        return true
    }
    
    class func isPic(frameID: Bytes) -> Bool {
        for i in 0...3 {
            if frameID[i] != FrameID.PIC[i] {
                return false
            }
        }
        return true
    }
    
    class func isComment(frameID: Bytes) -> Bool {
        for i in 0...3 {
            if frameID[i] != FrameID.COMM[i] {
                return false
            }
        }
        return true
    }
    
    class func shortDescription(data: Bytes, encoding : UInt, inout Size size: Int) -> String {
        
        var i = 0
        var str : [UInt8] = []
        
        while data[i] != 0x00 {
            str.append(data[i++])
        }
    
        size = i + 1
        
        return NSString(bytes: str, length: i, encoding: encoding)! as String
        
    }
    
    class func isUserDefindeURL(frameID: Bytes) -> Bool {
        for i in 0...3 {
            if frameID[i] != FrameID.UURL[i] {
                return false
            }
        }
        return true
    }
    
    /* Text Information frame */
    // MARK: - Text Information frame
    
    /*
    <Header for 'Text information frame', ID: "T000" - "TZZZ", excluding "TXXX" described in 4.2.2.>
    Text encoding    $xx
    Information    <text string according to encoding> */
    
    class func isEncodedBy(frameID: Bytes) -> Bool {
        
        for i in 0...3 {
            if frameID[i] != FrameID.ENCODED[i] {
                return false
            }
        }
        
        return true
    }
    
    /*
    <Header for 'Private frame', ID: "PRIV">
    Owner identifier        <text string> $00
    The private data        <binary data> */
    
    class func isPrivate(frameID: Bytes) -> Bool {
        
        for i in 0...3 {
            if frameID[i] != FrameID.PRIVATE[i] {
                return false
            }
        }
        
        return true
    }
    
    class func ownerIndentifier(data: Bytes, inout size: Int) -> String {
        var i = 0
        var str : [UInt8] = []
        
        while data[i] != 0x00 {
            str.append(data[i++])
        }
        str.append(data[i++])
        size = i
        
        return NSString(bytes: str, length: size, encoding: NSASCIIStringEncoding)! as String
    }
    
    class func isSortingAlbum(frameID: Bytes) -> Bool {
        for i in 0...3 {
            if frameID[i] != FrameID.SORT_ALBUM[i] {
                return false
            }
        }
        
        return true
    }
    
    

}