

import Foundation
import UIKit

class LocaleUtils {
    
    class func createLocaleFromCountryCode(countryCode:NSString)->NSLocale {
        return NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode:countryCode.uppercaseString]))
    }
    
    class func createLocaleFromCurrencyCode(currencyCode:String) -> NSLocale {
        return NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents([NSLocaleCurrencyCode:currencyCode.uppercaseString]))
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


func createLabel(text:String) -> UILabel{
    var label = UILabel()
    label.setTranslatesAutoresizingMaskIntoConstraints(false)
    label.text = text
    label.textAlignment = NSTextAlignment.Center
    label.numberOfLines = 2
    return label
}
