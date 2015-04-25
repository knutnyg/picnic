
import Foundation
import BrightFutures

class LocationManager : NSObject{
    
    var promiseInProgress = false
    var userModel:UserModel!
    
    var gpsLocationManager:GPSLocationManager!
    var celluarLocationManager:CelluarLocationManager!
    
    init(userModel:UserModel) {
        super.init()
        self.userModel = userModel
        gpsLocationManager = GPSLocationManager(userModel: userModel)
        celluarLocationManager = CelluarLocationManager()
    }
    
    func getUserCurrentLocale(withOverride:Bool) -> Future<NSLocale> {
        var promise = Promise<NSLocale>()
        self.promiseInProgress = true
        
        if withOverride {
            if let override = self.returnOverridedGPSLocationIfSet() {
                return Future<NSLocale>.succeeded(override)
            }
            return Future<NSLocale>.failed(NSError(domain: "Override inconsistent", code: 500, userInfo: nil))
        }
        gpsLocationManager.getUserCurrentLocale()
            .onSuccess { locale in
                promise.success(locale)
            }
            .onFailure { error in
                if let locale = self.celluarLocationManager.getCountryLocaleByCelluar() {
                    promise.success(locale)
                } else {
                    promise.failure(error)
                }
            }
        return promise.future
    }
    
    func returnOverridedGPSLocationIfSet() -> NSLocale?{
        if userModel.shouldOverrideGPS {
            if let override = userModel.overrideGPSLocale {
                println("locationmanager returning overrided GPS locale")
                println(LocaleUtils.createCountryNameFromLocale(override))
                return override
            }
        }
        return nil
    }
    
    func getUserHomeLocale(withOverride:Bool) -> NSLocale {
        if withOverride {
            if let override = self.returnOverridedLogicalLocationIfSet() {
                return override
            }
        }
        let countryCode:String =  getCountryCodeFromDevice()
        return LocaleUtils.createLocaleFromCountryCode(countryCode)
    }
    
    internal func getCountryCodeFromDevice() -> String{
        return NSLocale.autoupdatingCurrentLocale().objectForKey(NSLocaleCountryCode) as! String
    }

    
    
    func returnOverridedLogicalLocationIfSet() -> NSLocale?{
        if userModel.shouldOverrideLogical {
            if let override = userModel.overrideLogicalLocale {
                return override
            }
        }
        return nil
    }
}
