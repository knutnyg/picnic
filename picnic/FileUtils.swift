//
//  FileUtils.swift
//  picnic
//
//  Created by Knut Nygaard on 5/10/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation

func getFileURL(fileName: String) -> NSURL {
    let manager = NSFileManager.defaultManager()
    let dirURL: NSURL?
    do {
        dirURL = try manager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
    } catch _ {
        dirURL = nil
    }
    return dirURL!.URLByAppendingPathComponent(fileName)
}

func saveDictionaryToDisk(fileName:String, dict:Dictionary<String,AnyObject>){
    let filePath = getFileURL(fileName).path!
    NSKeyedArchiver.archiveRootObject(dict, toFile: filePath)
}

func readOfflineDateFromDisk(fileName:String) -> [String:OfflineEntry]? {
    print("Reading offline data from disk")
    if let filePath = getFileURL(fileName).path {
        if let dict = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String:OfflineEntry] {
            return dict
        }
    }
    return nil
}

func readFileAsString(filename:String, ofType:String) -> String?{
    let fileRoot = NSBundle.mainBundle().pathForResource(filename, ofType: ofType)
    if let root = fileRoot {
        var contents: NSString?
        do {
            contents = try NSString(contentsOfFile: root, encoding: NSUTF8StringEncoding)
        } catch _ {
            contents = nil
        }
        return contents as? String
    }
    
    return nil
    
}