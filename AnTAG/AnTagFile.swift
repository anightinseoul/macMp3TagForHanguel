//
//  AnTag.swift
//  AnMP3 Editer
//
//  Created by Younguk Wi on 2/18/16.
//  Copyright © 2016 ANightInSeoul. All rights reserved.
//

import Foundation

public class AnTagFile: NSObject {
    
    typealias Bytes = UnsafePointer<UInt8>
    
    let print_debug = false
    
    var version: Int = 0
    var title: String = ""
    var contentType: String = ""
    var year: String = ""
    var albumArtist: String = ""
    var album: String = ""
    var sortAlbum: String = ""
    var encodedBy: String = ""
    var singer: String = ""
    var copyRight: String = ""
    var unknownFrames: [[UInt8]]?
    var writeFrames: [[UInt8]]?
    var headerFrame: [UInt8]?
    
    var picture: Picture?
    var comment: Comment?
    var lyric: Comment?
    var uurl: UURL?
    var trackInfo: Track?
    var partOfSet: PartOfSet?
    
    let writeStringEncoding: NSStringEncoding = NSUTF16StringEncoding
    
    var mp3: NSData?
    
    var unSyncFlag: Bool = false
    var frameSize: Int = 0
    var fileName: String?
    var fileURL: NSURL?
    
    //temp
    var saveStart: NSDate?
    var saveEnd: NSDate?
    var readStart: NSDate?
    var readEnd: NSDate?
    
    struct Track {
        var song: String
        var total: String?
    }
    
    struct PartOfSet {
        var disc: String
        var total: String?
    }
    
    struct Picture {
        var MIMEType: String
        var picType: AnTagParser.PictureType
        var picDescripion: String
        var picImage: NSData?
    }
    
    struct Comment {
        var language: String?
        var shortDescription: String?
        var comment: String
        
        init(language: String?, shortDescription: String?, comment: String) {
            self.language = language
            self.shortDescription = shortDescription
            self.comment = comment
        }
        init(comment: String) {
            self.init(language: nil, shortDescription: nil, comment: comment)
        }
    }
    
    struct UURL {
        var description: String?
        var URL: NSURL
    }
    
    static let FRAME_ID_OFFSET = 4
    static let FRAME_ENCODING_OFFSET = 1
    static let FRAME_SIZE_OFFSET = 4
    static let FRAME_FLAG_OFFSET = 2
    static let HEADER_ID_OFFSET = 3
    static let HEADER_VERSION_OFFSET = 2
    static let HEADER_FLAG_OFFSET = 1
    static let HEADER_SIZE_OFFSET = 4
    
    static let HEADER_SIZE = HEADER_ID_OFFSET + HEADER_VERSION_OFFSET + HEADER_FLAG_OFFSET + HEADER_SIZE_OFFSET
    static let FRAME_HEADER_SIZE = FRAME_ID_OFFSET + FRAME_SIZE_OFFSET + FRAME_FLAG_OFFSET
    
    // MARK: - init
    
    init?(URL: NSURL) {
        
        print("Init")

        let mp3Data = NSData(contentsOfURL: URL)
        
        super.init()
        
        fileName = URL.lastPathComponent
        fileURL = URL
        if let mp3Data = mp3Data {
            readStart = NSDate()
            readHeader(mp3Data)
        } else {
            return nil
        }
        
        readEnd = NSDate()
        let interval = readEnd!.timeIntervalSinceDate(readStart!)
        if print_debug {
            print("Read : \(interval)")
        }
    }
    
    func nextFrame(let data: Bytes) -> Int {
        let frameCount = FrameID.IDArray.count
        
        for i in 0..<frameCount {
            
            if data[0] == FrameID.IDArray[i][0] && data[1] == FrameID.IDArray[i][1]
                && data[2] == FrameID.IDArray[i][2] && data[3] == FrameID.IDArray[i][3] {
                    let id = FrameID.FrameIDType(rawValue: i)
                    if let id = id {
                        switch id {
                        case FrameID.FrameIDType.TITLE:
                            //encoding(1) + Encoded String(xx)
                            
                            let values = AnTagParser.encodedStringWithSize(data, version: version)
                            self.title = values.encodedString as String
                            

                            return values.size
                            
                        case FrameID.FrameIDType.TRACK:

                            let values = AnTagParser.encodedStringWithSize(data, version: version)
                            
                            let track = values.encodedString as String
                            
                            if print_debug {
                                print("TRACK : \(track)")
                            }
                            
                            let eachTrack = track.componentsSeparatedByString("/")
                            
                            if eachTrack.count == 2 {
                                self.trackInfo = Track(song: eachTrack[0], total: eachTrack[1])
                            } else {
                                self.trackInfo = Track(song: eachTrack[0], total: nil)
                            }
                            
                            return values.size
                            
                        case FrameID.FrameIDType.TYPE:

                            let values = AnTagParser.encodedStringWithSize(data, version: version)
                            
                            self.contentType = values.encodedString as String

                            return values.size

                        case FrameID.FrameIDType.YEAR:

                            let values = AnTagParser.encodedStringWithSize(data, version: version)
                            
                            self.year = values.encodedString as String

                            return values.size

                        case FrameID.FrameIDType.BAND:
                            
                            let values = AnTagParser.encodedStringWithSize(data, version: version)
                            
                            self.albumArtist = values.encodedString as String

                            return values.size
                            
                        case FrameID.FrameIDType.ALBUM:

                            let values = AnTagParser.encodedStringWithSize(data, version: version)
                            
                            self.album = values.encodedString as String

                            return values.size
                            
                        /*case FrameID.FrameIDType.SORT_ALBUM:
                            let values = AnTagParser.encodedStringWithSize(data, type: AnTagParser.FrameStructType.EnCodedText, version: version)
                            
                            self.sortAlbum = values.encodedString as String
                            print("SORT_ALBUM : \(sortAlbum)")

                            return values.size*/
                            
                        case FrameID.FrameIDType.PERFORMER:

                            let values = AnTagParser.encodedStringWithSize(data, version: version)
                            
                            self.singer = values.encodedString as String

                            return values.size
                            
                        case FrameID.FrameIDType.PART:

                            let values = AnTagParser.encodedStringWithSize(data, version: version)
                            
                            let disc = values.encodedString as String
                            let eachDisc = disc.componentsSeparatedByString("/")
                            
                            if eachDisc.count == 2 {
                                self.partOfSet = PartOfSet(disc: eachDisc[0], total: eachDisc[1])
                            } else {
                                self.partOfSet = PartOfSet(disc: eachDisc[0], total: nil)
                            }

                            return values.size
                            
                        /*case FrameID.FrameIDType.COPY:
                            let values = AnTagParser.encodedStringWithSize(data, type: AnTagParser.FrameStructType.EnCodedText, version: version)
                            
                            self.copyRight = values.encodedString as String
                            print("COPY : \(copyRight)")
                            return values.size
                            
                        case FrameID.FrameIDType.ENCODED:
                            let values = AnTagParser.encodedStringWithSize(data, type: AnTagParser.FrameStructType.EnCodedText, version: version)
                            
                            self.encodedBy = values.encodedString as String
                            print("ENCODED : \(encodedBy)")

                            return values.size*/
                            
                        case FrameID.FrameIDType.PIC:

/*
<Header for 'Attached picture', ID: "APIC">
Text encoding   $xx
MIME type       <text string> $00
Picture type    $xx
Description     <text string according to encoding> $00 (00)
Picture data    <binary data> */
                            
                            let returnValues = AnTagParser.prictureWithSize(data, version: version)
                            
                            self.picture = Picture(MIMEType: returnValues.MIMEType, picType: returnValues.picType, picDescripion: returnValues.picDescription, picImage: returnValues.picImage)
                            
                            
                            if print_debug {
                                print("PIC : \(returnValues.MIMEType), picDescripion : \(returnValues.picDescription).")
                            }
                            
                            return returnValues.readLength
                            
                        case FrameID.FrameIDType.COMM:
                            
                            /*
<Header for 'Comment', ID: "COMM">
Text encoding           $xx
Language                $xx xx xx
Short content descrip.  <text string according to encoding> $00 (00)
The actual text         <full text string according to encoding> */
                            
                            let returnValues = AnTagParser.commWithSize(data, version: version)
                            
                            self.comment = Comment(language: returnValues.lan, shortDescription: returnValues.shortDescription, comment: returnValues.comments)
                            
                            return returnValues.readLength
                            
                        case FrameID.FrameIDType.LYRIC:

/* <Header for 'Unsynchronised lyrics/text transcription', ID: "USLT">
Text encoding       $xx
Language            $xx xx xx
Content descriptor  <text string according to encoding> $00 (00)
Lyrics/text         <full text string according to encoding> */
                            
                            let returnValues = AnTagParser.commWithSize(data, version: version)
                            
                            self.lyric = Comment(language: returnValues.lan, shortDescription: returnValues.shortDescription, comment: returnValues.comments)
                            
                            if print_debug {
                                print("LYRIC : \(lyric)")
                            }

                            return returnValues.readLength

                            /*
                        case FrameID.FrameIDType.UURL:

                            /* <Header for 'User defined URL link frame', ID: "WXXX">
                            Text encoding    $xx
                            Description    <text string according to encoding> $00 (00)
                            URL    <text string> */
                            
                            let returnValues = AnTagParser.urlWithSize(data, version: version)
                            
                            self.uurl = UURL(description: returnValues.description, URL: NSURL(string: returnValues.URL)!)
                            
                            if print_debug {
                                print("UURL : \(uurl)")
                            }

                            return returnValues.readLength
                            */
                        /*case FrameID.FrameIDType.PRIVATE:
                            /*
                            <Header for 'Private frame', ID: "PRIV">
                            Owner identifier        <text string> $00
                            The private data        <binary data> */
                            
                            var offset = FRAME_ID_OFFSET
                            let frameSize = AnTagParser.frameSize(data + offset, version: version)
                            
                            offset += FRAME_FLAG_OFFSET + FRAME_SIZE_OFFSET // size(4) + flag(2)
                            
                            var size = 0
                            let owner = AnTagParser.ownerIndentifier(data + offset, size: &size)
                            print("owner : \(owner)")
                            offset += size
                            
                            let Binary = NSString(bytes: data + offset, length: frameSize - size, encoding: NSASCIIStringEncoding)!
                            print("Binary : \(Binary)")
                            offset += frameSize - size
                            print("PRIVATE : \(owner), Binary : \(Binary)")

                            return offset*/
                        default:
                            if print_debug {
                                print("UNKNOWUN")
                            }
                            
                        }
                        
                        
                    }
                    
            }
        }
        
        if data[0] == 0x00 && data[1] == 0x00 {
            if print_debug {
                print("Meet Padding, End Parsing")
            }
                return -1
        }
        

        let unknownLength = AnTagParser.skipFrame(data, version: version)

        var unknownFrame = [UInt8](count:unknownLength, repeatedValue: 0x00)
        for i in 0..<unknownLength {
            unknownFrame[i] = data[i]
        }
        
        if unknownFrames == nil {
            unknownFrames = Array()
        }

        unknownFrames!.append(unknownFrame)
        
        return unknownLength
    }
    
    func readHeader(mp3Data: NSData) {
        var i = 0
        let bytes = UnsafePointer<UInt8>(mp3Data.bytes)
        if AnTagParser.isID3v2Tag(bytes) {
            headerFrame = [UInt8](count: AnTagFile.HEADER_SIZE, repeatedValue: 0x00)
            
            for ; i < AnTagFile.HEADER_SIZE; i++ {
                headerFrame![i] = bytes[i]
            }
            
            headerFrame![5] = 0 //Reset Flag

            var frameBytes = bytes + AnTagFile.HEADER_SIZE
            
            frameSize = AnTagParser.iD3v2Size(bytes)
            version = AnTagParser.subVersion(bytes)!.0
            
            if version != 3 && version != 4 {
                print("Not support Version")
            } else {

                unSyncFlag = AnTagParser.isUnsync(bytes)
                var unSyncBytes = [UInt8](count: frameSize, repeatedValue: 0)
                var length = frameSize

                if unSyncFlag && version == 3 {
                    // FF 00 -> FF
                    length = AnTagParser.unSynchro(bytes + AnTagFile.FRAME_HEADER_SIZE, to: &unSyncBytes, size: frameSize)
                    frameBytes = UnsafePointer<UInt8>(unSyncBytes)
                }

                readFrames(frameBytes, frameSize: length)

            }
        }
        
        let TagSize = frameSize
        
        if print_debug {
            print("TagSize : \(TagSize)")
        }
        
//TODO: Temp
        mp3 = NSData(bytes: bytes + TagSize, length: mp3Data.length - TagSize)

    }
    
    func readFrames(bytes: Bytes, frameSize: Int) {
        
        var readSize = 0
        var data = bytes

        if print_debug {
            print("frameSize : \(frameSize)")
        }
        
        while frameSize > readSize {
            
            let length = nextFrame(data)

            if length == -1 {
                break
            }
            
            data += length
            readSize += length
            if print_debug {
                print("Read size : \(length), total: \(readSize)")
            }
        }
        
        if print_debug {
            print("End")
        }
    }
    
    func checkTagHeader() {
        
        if headerFrame == nil {
            headerFrame = [UInt8](count: AnTagFile.HEADER_SIZE, repeatedValue: 0x00)
            
            //set "ID3"
            AnTagParser.setID3v2Tag(&headerFrame!)
            
            //set version
            //default is 4
            headerFrame![3] = 4
            headerFrame![4] = 0
            
            version = 4
            
        }
    }
    
    func saveTag() throws {
        let BOM = 2
        
        if writeFrames == nil {
            writeFrames = Array()
        }
        
        if print_debug {
            print("writeFrames : \(writeFrames!.count)")
        }
        
        // TAG Header check
        checkTagHeader()
        
        //encoding(1) + Encoded String(xx)
        if !title.isEmpty {
            var i = 0
            let frameSize = AnTagFile.FRAME_ENCODING_OFFSET + title.lengthOfBytesUsingEncoding(writeStringEncoding) + BOM //BOM
            
            if unSyncFlag && version == 4 {
                
            }

            var writeFrame = [UInt8](count: frameSize + AnTagFile.FRAME_HEADER_SIZE, repeatedValue: 0x00)
            //var writeFrame: [UInt8] = []
            
            for i = 0; i < AnTagFile.FRAME_ID_OFFSET; i++ {
                writeFrame[i] = FrameID.TITLE[i]
            }
            
            AnTagParser.writeTextFrame(&writeFrame, text: title, frameSize: frameSize, version: version, Index: i, writeStringEncoding: writeStringEncoding, unSyncFlag: unSyncFlag)
            
            writeFrames!.append(writeFrame)
        }
    
        if !singer.isEmpty {
            var i = 0
            let frameSize = AnTagFile.FRAME_ENCODING_OFFSET + singer.lengthOfBytesUsingEncoding(writeStringEncoding) + BOM
            var writeFrame = [UInt8](count: AnTagFile.FRAME_HEADER_SIZE + frameSize, repeatedValue: 0x00)
            
            for i = 0; i < AnTagFile.FRAME_ID_OFFSET; i++ {
                writeFrame[i] = FrameID.PERFORMER[i]
            }
            
            AnTagParser.writeTextFrame(&writeFrame, text: singer, frameSize: frameSize, version: version, Index: i, writeStringEncoding: writeStringEncoding, unSyncFlag: unSyncFlag)

            writeFrames!.append(writeFrame)
        }
        
        if !year.isEmpty {
            var i = 0
            let frameSize = AnTagFile.FRAME_ENCODING_OFFSET + year.lengthOfBytesUsingEncoding(writeStringEncoding) + BOM
            var writeFrame = [UInt8](count: AnTagFile.FRAME_HEADER_SIZE + frameSize, repeatedValue: 0x00)
            
            for i = 0; i < AnTagFile.FRAME_ID_OFFSET; i++ {
                writeFrame[i] = FrameID.YEAR[i]
            }
            
            AnTagParser.writeTextFrame(&writeFrame, text: year, frameSize: frameSize, version: version, Index: i, writeStringEncoding: writeStringEncoding, unSyncFlag: unSyncFlag)
            
            writeFrames!.append(writeFrame)
        }
        
        if !album.isEmpty {
            var i = 0
            let frameSize = AnTagFile.FRAME_ENCODING_OFFSET + album.lengthOfBytesUsingEncoding(writeStringEncoding) + BOM
            var writeFrame = [UInt8](count: AnTagFile.FRAME_HEADER_SIZE + frameSize, repeatedValue: 0x00)
            
            for i = 0; i < AnTagFile.FRAME_ID_OFFSET; i++ {
                writeFrame[i] = FrameID.ALBUM[i]
            }
            
            AnTagParser.writeTextFrame(&writeFrame, text: album, frameSize: frameSize, version: version, Index: i, writeStringEncoding: writeStringEncoding, unSyncFlag: unSyncFlag)
            
            writeFrames!.append(writeFrame)
        }
        
        if let trackInfo = trackInfo {
            var track: String = ""
            if !trackInfo.song.isEmpty && trackInfo.total != nil && !trackInfo.total!.isEmpty {
                // 둘다
                track = trackInfo.song + "/" + trackInfo.total!
            } else if !trackInfo.song.isEmpty {
                // only track number
                track = trackInfo.song
            } else if trackInfo.total != nil && !trackInfo.total!.isEmpty {
                // only totla track count ???
                track = "/" + trackInfo.total!
            }
            
            var i = 0
            let frameSize = AnTagFile.FRAME_ENCODING_OFFSET + track.lengthOfBytesUsingEncoding(writeStringEncoding) + BOM
            var writeFrame = [UInt8](count: AnTagFile.FRAME_HEADER_SIZE + frameSize, repeatedValue: 0x00)
            
            for i = 0; i < AnTagFile.FRAME_ID_OFFSET; i++ {
                writeFrame[i] = FrameID.TRACK[i]
            }
            
            AnTagParser.writeTextFrame(&writeFrame, text: track, frameSize: frameSize, version: version, Index: i, writeStringEncoding: writeStringEncoding, unSyncFlag: unSyncFlag)
            
            writeFrames!.append(writeFrame)
        }
        
        if let partOfSet = partOfSet {
            var part: String = ""
            if !partOfSet.disc.isEmpty && partOfSet.total != nil && !partOfSet.total!.isEmpty {
                // 둘다
                part = partOfSet.disc + "/" + partOfSet.total!
            } else if !partOfSet.disc.isEmpty {
                // only track number
                part = partOfSet.disc
            } else if partOfSet.total != nil && !partOfSet.total!.isEmpty {
                // only totla track count ???
                part = "/" + partOfSet.total!
            }
            
            var i = 0
            let frameSize = AnTagFile.FRAME_ENCODING_OFFSET + part.lengthOfBytesUsingEncoding(writeStringEncoding) + BOM
            var writeFrame = [UInt8](count: AnTagFile.FRAME_HEADER_SIZE + frameSize, repeatedValue: 0x00)
            
            for i = 0; i < AnTagFile.FRAME_ID_OFFSET; i++ {
                writeFrame[i] = FrameID.PART[i]
            }
            
            AnTagParser.writeTextFrame(&writeFrame, text: part, frameSize: frameSize, version: version, Index: i, writeStringEncoding: writeStringEncoding, unSyncFlag: unSyncFlag)
            
            writeFrames!.append(writeFrame)
        }
        
        if !albumArtist.isEmpty {
            var i = 0
            let frameSize = AnTagFile.FRAME_ENCODING_OFFSET + albumArtist.lengthOfBytesUsingEncoding(writeStringEncoding) + BOM
            var writeFrame = [UInt8](count: AnTagFile.FRAME_HEADER_SIZE + frameSize, repeatedValue: 0x00)
            
            for i = 0; i < AnTagFile.FRAME_ID_OFFSET; i++ {
                writeFrame[i] = FrameID.BAND[i]
            }
            
            AnTagParser.writeTextFrame(&writeFrame, text: albumArtist, frameSize: frameSize, version: version, Index: i, writeStringEncoding: writeStringEncoding, unSyncFlag: unSyncFlag)
            
            writeFrames!.append(writeFrame)
        }
        
        if !contentType.isEmpty {
            var i = 0
            let frameSize = AnTagFile.FRAME_ENCODING_OFFSET + contentType.lengthOfBytesUsingEncoding(writeStringEncoding) + BOM
            var writeFrame = [UInt8](count: AnTagFile.FRAME_HEADER_SIZE + frameSize, repeatedValue: 0x00)
            
            for i = 0; i < AnTagFile.FRAME_ID_OFFSET; i++ {
                writeFrame[i] = FrameID.TYPE[i]
            }
            
            AnTagParser.writeTextFrame(&writeFrame, text: contentType, frameSize: frameSize, version: version, Index: i, writeStringEncoding: writeStringEncoding, unSyncFlag: unSyncFlag)
            
            writeFrames!.append(writeFrame)
        }
        
/*
var lyric: Comment?
var uurl: UURL?
*/
        if let lyric = lyric {
            let lanSize = 3
            var descriptionSize: Int = 2
            let textSize = lyric.comment.lengthOfBytesUsingEncoding(writeStringEncoding) + BOM
            
            /*
            var language: String?
            var shortDescription: String?
            var comment: String
            
            <Header for 'Comment', ID: "COMM">
            Text encoding           $xx
            Language                $xx xx xx
            Short content descrip.  <text string according to encoding> $00 (00)
            The actual text         <full text string according to encoding> */
            
            if let description = lyric.shortDescription {
                descriptionSize += description.lengthOfBytesUsingEncoding(writeStringEncoding) + BOM
            }
            
            let frameSize = AnTagFile.FRAME_ENCODING_OFFSET + lanSize + descriptionSize + textSize
            
            // HEADER
            var writeFrame = [UInt8](count: AnTagFile.FRAME_HEADER_SIZE + frameSize, repeatedValue: 0x00)
            var i = 0
            for ; i < AnTagFile.FRAME_ID_OFFSET; i++ {
                writeFrame[i] = FrameID.LYRIC[i]
            }
            
            AnTagParser.writeCommentFrame(&writeFrame, contents: lyric, frameSize: frameSize, version: version, Index: i, writeStringEncoding: writeStringEncoding)
            writeFrames!.append(writeFrame)
        }
        
        if let comment = comment {
            let lanSize = 3
            var descriptionSize: Int = 2
            let textSize = comment.comment.lengthOfBytesUsingEncoding(writeStringEncoding) + BOM
            
            /*
            var language: String?
            var shortDescription: String?
            var comment: String
            
            <Header for 'Comment', ID: "COMM">
            Text encoding           $xx
            Language                $xx xx xx
            Short content descrip.  <text string according to encoding> $00 (00)
            The actual text         <full text string according to encoding> */
            
            if let description = comment.shortDescription {
                descriptionSize += description.lengthOfBytesUsingEncoding(writeStringEncoding) + BOM
            }
            
            let frameSize = AnTagFile.FRAME_ENCODING_OFFSET + lanSize + descriptionSize + textSize
            
            // HEADER
            var writeFrame = [UInt8](count: AnTagFile.FRAME_HEADER_SIZE + frameSize, repeatedValue: 0x00)
            var i = 0
            
            for ; i < AnTagFile.FRAME_ID_OFFSET; i++ {
                writeFrame[i] = FrameID.COMM[i]
            }
            
            AnTagParser.writeCommentFrame(&writeFrame, contents: comment, frameSize: frameSize, version: version, Index: i, writeStringEncoding: writeStringEncoding)
            writeFrames!.append(writeFrame)
        }
        
        if let picture = picture {
            if let picImage = picture.picImage {
                
                // mime type check
                var mimeType = picture.MIMEType
                
                if picture.MIMEType.hasPrefix("image/jpeg") {
                    mimeType = "image/jpeg"
                }
                
                let MIMELength = mimeType.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) + 1
                if MIMELength < 10 {
                    print("!!!! : \(MIMELength)")
                    var i = 3
                    i++
                    
                }
                //let descriptionLength = picture.picDescripion.lengthOfBytesUsingEncoding(writeStringEncoding) + 2 + BOM
                print(picture.picDescripion)
                let descriptionLength = picture.picDescripion.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) + 1
                
                let frameSize = AnTagFile.FRAME_ENCODING_OFFSET + MIMELength + 1 + descriptionLength + picImage.length
                
                var writeFrame = [UInt8](count: AnTagFile.FRAME_HEADER_SIZE + frameSize, repeatedValue: 0x00)
                var i = 0
                
                for i = 0; i < AnTagFile.FRAME_ID_OFFSET; i++ {
                    writeFrame[i] = FrameID.PIC[i]
                }
                
                let sizeArray = AnTagParser.generateSize(frameSize, version: version)
                for var j = 0; j < 4; j++ {
                    writeFrame[i++] = sizeArray[j]
                }
                
                writeFrame[i++] = 0x00
                writeFrame[i++] = 0x00
                
                writeFrame[i++] = AnTagParser.revertEncoding(NSASCIIStringEncoding)
                
                // MIME type
                let mime = UnsafePointer<UInt8>(picture.MIMEType.dataUsingEncoding(NSASCIIStringEncoding)!.bytes)
                for var j = 0; j < MIMELength - 1; i++, j++ {
                    writeFrame[i] = mime[j]
                }
                writeFrame[i++] = 0x00
                
                // Picture Type
                writeFrame[i++] = UInt8(picture.picType.rawValue)

                //Description
                let des = UnsafePointer<UInt8>(picture.picDescripion.dataUsingEncoding(NSASCIIStringEncoding)!.bytes)
                for var j = 0; j < descriptionLength - 1; i++, j++ {
                    writeFrame[i] = des[j]
                }
                writeFrame[i++] = 0x00

                // Picture Data
                let picData = UnsafePointer<UInt8>(picImage.bytes)
                for var j = 0; j < picImage.length; j++, i++ {
                    writeFrame[i] = picData[j]
                }
                
                writeFrames!.append(writeFrame)
                
            }
            
        }
        
        /*
        if let uurl = uurl {
            

            var descriptionLength = 0
            
            if let description = uurl.description {
                descriptionLength += description.lengthOfBytesUsingEncoding(writeStringEncoding) + BOM
            }
            let urlLength = uurl.URL.absoluteString.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)
            
            let frameSize = AnTagFile.FRAME_ENCODING_OFFSET + descriptionLength + urlLength
            
            var writeFrame = [UInt8](count: AnTagFile.FRAME_HEADER_SIZE + frameSize, repeatedValue: 0x00)
            
            var i = 0
            for ; i < AnTagFile.FRAME_ID_OFFSET; i++ {
                writeFrame[i] = FrameID.UURL[i]
            }
            
            // Size
            let sizeArray = AnTagParser.generateSize(frameSize, version: version)
            for var j = 0; j < AnTagFile.FRAME_SIZE_OFFSET; i++, j++ {
                writeFrame[i] = sizeArray[j]
            }
            
            // Flag
            writeFrame[i++] = 0x00
            writeFrame[i++] = 0x00
            
            // Encoding
            writeFrame[i++] = AnTagParser.revertEncoding(writeStringEncoding)
            
            // Description
            if let description = uurl.description {
                let desBytes = UnsafePointer<UInt8>(description.dataUsingEncoding(writeStringEncoding)!.bytes)
                for var j = 0; j < descriptionLength - 2; i++, j++ {
                    writeFrame[i] = desBytes[j]
                }
            }
            writeFrame[i++] = 0x00
            writeFrame[i++] = 0x00
            
            // URL
            let urlBytes = UnsafePointer<UInt8>(uurl.URL.absoluteString.dataUsingEncoding(NSASCIIStringEncoding)!.bytes)
            for var j = 0; j < urlLength; i++, j++ {
                writeFrame[i] = urlBytes[j]
            }

            writeFrames!.append(writeFrame)
        }*/
        
        // add unknownFrames
        if let unknownFrames = unknownFrames {
            if print_debug {
                print("unkonwnFrames : \(unknownFrames.count)")
            }
            for var i = 0; i < unknownFrames.count; i++ {
                writeFrames!.append(unknownFrames[i])
            }
        }
        
        /*
        if unSyncFlag && version == 3 {
            var syncBytes: [[UInt8]] = []
            
            if unSyncFlag && version == 3 {
                // FF 00 -> FF
                AnTagParser.synchro(writeFrames, to: &syncBytes)
            }
            
            do {
                try saveMP3(generateToTalSize(syncBytes), writeFrames: syncBytes)
            } catch let error as NSError {
                throw error
            }
            
        } else {
            do {
                try saveMP3(generateToTalSize(writeFrames), writeFrames: writeFrames)
            } catch let error as NSError {
                throw error
            }
        }*/
        
        do {
            try saveMP3(generateToTalSize(writeFrames), writeFrames: writeFrames)
        } catch let error as NSError {
            throw error
        }
    }
    
    func saveMP3(frameSize: Int, writeFrames: [[UInt8]]?) throws {
        let size = AnTagFile.HEADER_SIZE + frameSize
        var mp3File = [UInt8](count: size, repeatedValue: 0x00)
        
        var i = 0
        for ; i < AnTagFile.HEADER_SIZE; i++ {
            mp3File[i] = headerFrame![i]
        }
        
        let tagData = NSMutableData(bytes: mp3File, length: AnTagFile.HEADER_SIZE)
        
        saveStart = NSDate()
        if let writeFrames = writeFrames {
            for var j = 0; j < writeFrames.count; j++ {
                tagData.appendBytes(writeFrames[j], length: writeFrames[j].count)
            }
        }
        saveEnd = NSDate()
        

        
        let fullData = NSMutableData()
        fullData.appendData(tagData)
        fullData.appendData(mp3!)
        
        if print_debug {
            print(saveEnd!.timeIntervalSinceDate(saveStart!))
        }
        
        do {
            try fullData.writeToURL(fileURL!, options: NSDataWritingOptions(rawValue: 1))
        } catch let error as NSError {
            initWriteFrames()
            
            print("Error : \(error)")
            throw error
        }
        initWriteFrames()
    }
    
    func initWriteFrames() {
        writeFrames = nil
    }
    
    func generateToTalSize(writeFrames: [[UInt8]]?) -> Int {
        var size = 0

        if let writeFrames = writeFrames {
            for var i = 0; i < writeFrames.count; i++ {
                size += writeFrames[i].count
            }
        
            let sizeArray = AnTagParser.generateSize(size, version: 4) //sync safe type
            
            for var i = 6, j = 0; j < AnTagFile.HEADER_SIZE_OFFSET; i++, j++ {
                self.headerFrame![i] = sizeArray[j]
            }
        }
        
        return size
    }
}