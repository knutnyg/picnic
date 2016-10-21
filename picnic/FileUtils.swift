//
//  FileUtils.swift
//  picnic
//
//  Created by Knut Nygaard on 5/10/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation

func getFileURL(_ fileName: String) -> URL? {
    do {
        return  try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)
    }
    catch {
        print("Error loading file from device...")
    }
    return nil
}

func saveDictionaryToDisk(_ fileName:String, dict:Dictionary<String,AnyObject>){
    if let filePath = getFileURL(fileName) {
        NSKeyedArchiver.archiveRootObject(dict, toFile: filePath.path)
    }
}

func readOfflineDateFromDisk(_ fileName:String) -> [String:OfflineEntry]? {
    print("Reading offline data from disk")
    if let filePath = getFileURL(fileName) {
        if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.path) as? [String:OfflineEntry] {
            return dict
        }
    }
    return nil
}

func readFileAsString(_ filename:String, ofType:String) -> String?{
    if let root = Bundle.main.path(forResource: filename, ofType: ofType) {
        do{
            return try NSString(contentsOfFile: root, encoding: String.Encoding.utf8.rawValue) as String
        } catch {
            print("failed reading file...")
        }
    }
    return nil
}
