

import Foundation
import UIKit

class LocaleUtils {
    
    class func createLocaleFromCountryCode(_ countryCode:NSString)->Locale {
        return Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue:countryCode.uppercased]))
    }
    
    class func createLocaleFromCurrencyCode(_ currencyCode:String) -> Locale {
        return Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.currencyCode.rawValue:currencyCode.uppercased()]))
    }
    
    class func createCountryNameFromLocale(_ locale:Locale, languageLocale:Locale? = nil) -> String? {
        let countryCode: String? = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String
        if let cc = countryCode {
            if let loc = languageLocale {
                return (loc as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: cc)
            } else {
                return (Locale(identifier: "en_US") as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: cc)
            }
        }
        return nil
    }
    
    class func createCurrencyCodeFromLocale(_ locale:Locale) -> NSString?{
        return (locale as NSLocale).object(forKey: NSLocale.Key.currencyCode) as? String as NSString?
    }
    
    class func createLocaleCountryNameTuple(_ locale:Locale, language:Locale) -> LocaleCountryNameTuple{
        let countryName = createCountryNameFromLocale(locale, languageLocale: language)!
        return LocaleCountryNameTuple(locale: locale, countryName: countryName)
    }
}

func dateFromUTCString(_ dateOnUTC:String) -> Date{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return dateFormatter.date(from: dateOnUTC)!
}


func createLabel(_ text:String) -> UILabel{
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = text
    label.textAlignment = NSTextAlignment.center
    label.numberOfLines = 2
    return label
}
