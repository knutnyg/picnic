

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
