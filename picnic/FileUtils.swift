//
//  FileUtils.swift
//  picnic
//
//  Created by Knut Nygaard on 5/10/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation

func getFileURL(fileName: String) -> NSURL? {
    do {
        return  try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false).URLByAppendingPathComponent(fileName)
    }
    catch {
        print("Error loading file from device...")
    }
    return nil
}

func saveDictionaryToDisk(fileName:String, dict:Dictionary<String,AnyObject>){
    if let filePath = getFileURL(fileName) {
        NSKeyedArchiver.archiveRootObject(dict, toFile: filePath.path!)
    }
}

func readOfflineDateFromDisk(fileName:String) -> [String:OfflineEntry]? {
    print("Reading offline data from disk")
    if let filePath = getFileURL(fileName) {
        if let dict = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath.path!) as? [String:OfflineEntry] {
            return dict
        }
    }
    return nil
}

func readFileAsString(filename:String, ofType:String) -> String?{
    if let root = NSBundle.mainBundle().pathForResource(filename, ofType: ofType) {
        do{
            return try NSString(contentsOfFile: root, encoding: NSUTF8StringEncoding) as String
        } catch {
            print("failed reading file...")
        }
    }
    return nil
}