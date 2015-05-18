
import Foundation
import BrightFutures

class LocationManager : NSObject{
    
    var userModel:UserModel!
    var currentLocationPromise:Promise<NSLocale>!
    
    var gpsLocationManager:GPSLocationManager!
    
    init(userModel:UserModel) {
        super.init()
        self.userModel = userModel
        gpsLocationManager = GPSLocationManager(userModel: userModel)
    }
    
    func getUserCurrentLocale(withOverride:Bool) -> Future<NSLocale> {
        currentLocationPromise = Promise<NSLocale>()
        
        if withOverride {
            if userModel.shouldOverrideGPS {
                if let locale = userModel.overrideGPSLocale {
                    return Future<NSLocale>.succeeded(locale)
                } else {
                    return Future<NSLocale>.failed(NSError(domain: "Override inconsistent", code: 500, userInfo: nil))
                }
            }
        }
        gpsLocationManager.getUserCurrentLocale()
            .onSuccess { locale in
                self.currentLocationPromise.success(locale)
            }
            .onFailure { error in
                self.currentLocationPromise.failure(error)
            }
        return currentLocationPromise.future
    }
    
    func stopGatheringGPSLocaiton(){
        if gpsLocationManager.promiseInProgress {
            gpsLocationManager.locationManager.stopUpdatingLocation()
            currentLocationPromise.complete(Result<NSLocale>(NSLocale(localeIdentifier: "en_US")))
        }
    }
    
    func returnOverridedGPSLocationIfSet() -> NSLocale?{
        if userModel.shouldOverrideGPS {
            if let override = userModel.overrideGPSLocale {
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
