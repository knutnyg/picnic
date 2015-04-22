
import Foundation
import CoreTelephony



class CelluarLocationManager {

    class func getCountryLocaleByCelluar() -> NSLocale?{
        var networkInfo:CTTelephonyNetworkInfo? = CTTelephonyNetworkInfo()
        var isoCountryCode:String!
        if let ni = networkInfo, carrier = ni.subscriberCellularProvider {
            isoCountryCode = carrier.isoCountryCode
        }
        if let icc = isoCountryCode {
            return LocaleUtils.createLocaleFromCountryCode(icc)
        } else {
            println("Error: Celluar icc is nil!")
        }
        return nil
    }
    
}
