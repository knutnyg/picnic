

import Foundation

class LocaleUtils {
    
    class func createLocaleFromCountryCode(countryCode:NSString)->NSLocale {
        return NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode:countryCode.uppercaseString]))
    }
    
    class func createCountryNameFromLocale(locale:NSLocale, languageLocale:NSLocale? = nil) -> String? {
        let countryCode: String? = locale.objectForKey(NSLocaleCountryCode) as? String
        if let cc = countryCode {
            if let loc = languageLocale {
                return languageLocale?.displayNameForKey(NSLocaleCountryCode, value: cc)
            } else {
                return NSLocale(localeIdentifier: "en_US").displayNameForKey(NSLocaleCountryCode, value: cc)
            }

        }
        return nil
    }
    
    class func createLocaleCountryNameTuple(locale:NSLocale, language:NSLocale) -> LocaleCountryNameTuple{
        var countryName = createCountryNameFromLocale(locale, languageLocale: language)!
        return LocaleCountryNameTuple(locale: locale, countryName: countryName)
    }
}

func dateFromUTCString(dateOnUTC:String) -> NSDate{
    var dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return dateFormatter.dateFromString(dateOnUTC)!
}

func getFileURL(fileName: String) -> NSURL {
    let manager = NSFileManager.defaultManager()
    let dirURL = manager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false, error: nil)
    return dirURL!.URLByAppendingPathComponent(fileName)
}

func saveDictionaryToDisk(fileName:String, dict:Dictionary<String,AnyObject>){
    let filePath = getFileURL(fileName).path!
    NSKeyedArchiver.archiveRootObject(dict, toFile: filePath)
}

func readOfflineDateFromDisk(fileName:String) -> [String:OfflineEntry]? {
    println("Reading offline data from disk")
    if let filePath = getFileURL(fileName).path {
        if let dict = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String:OfflineEntry] {
            return dict
        }
    }
    return nil
}

