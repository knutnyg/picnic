
import Foundation
import CoreTelephony



class CelluarLocationManager {

    func getCountryLocaleByCelluar() -> NSLocale?{
        
        if let cc = getCountryCodeFromSim() {
            return LocaleUtils.createLocaleFromCountryCode(cc)
        } else {
            println("Error: Celluar icc is nil!")
        }
        return nil
    }
    
    internal func getCountryCodeFromSim() -> String?{
        var networkInfo:CTTelephonyNetworkInfo? = CTTelephonyNetworkInfo()

        if let ni = networkInfo, carrier = ni.subscriberCellularProvider {
            return carrier.isoCountryCode
        } else {
            return nil
        }
        

        
    }
    
}
