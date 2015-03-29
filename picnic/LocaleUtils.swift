

import Foundation

class LocaleUtils {
    
    class func createLocaleFromCountryCode(countryCode:NSString)->NSLocale {
        return NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode:countryCode]))
    }
    
    class func createCountryNameFromLocale(locale:NSLocale) -> String? {
        let countryCode: String? = locale.objectForKey(NSLocaleCountryCode) as? String
        if let cc = countryCode {
            return locale.displayNameForKey(NSLocaleCountryCode, value: cc)
        }
        return nil
    }
}
