
import Foundation
import CoreLocation
import BrightFutures
import CoreTelephony


class GPSLocationManager : NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var promise:Promise<NSLocale>?
    var userModel:UserModel!
    
    init(userModel:UserModel) {
        super.init()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.requestWhenInUseAuthorization()
        self.userModel = userModel
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler:
            {
                (placemarks, error)->Void in

                if error != nil {
                    self.handleError(error)
                    self.locationManager.stopUpdatingLocation()
                } else {
                    self.handleLocation(placemarks)
                }

            }
        )
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
    
    func returnOverridedLogicalLocationIfSet() -> NSLocale?{
        if userModel.shouldOverrideLogical {
            if let override = userModel.overrideLogicalLocale {
                return override
            }
        }
        return nil
    }
    
    func handleLocation(placemarks: [AnyObject]) {
        if placemarks.isEmpty {
            println("Error with the data.")
        } else {
            let pm:CLPlacemark = placemarks.first as! CLPlacemark
            let locale:NSLocale = LocaleUtils.createLocaleFromCountryCode(pm.ISOcountryCode)
            
            self.promise!.success(locale)
            locationManager.stopUpdatingLocation()
        }
    }    

    func getUserCurrentLocale(withOverride:Bool) -> Future<NSLocale> {
        self.promise = Promise<NSLocale>()

        if withOverride {
            if let override = self.returnOverridedGPSLocationIfSet() {
                self.promise!.success(override)
                return promise!.future
            }
        }
        
        self.locationManager.startUpdatingLocation()
        return self.promise!.future
    }
    
    func getUserHomeLocale(withOverride:Bool) -> NSLocale {
        if withOverride {
            if let override = self.returnOverridedLogicalLocationIfSet() {
                return override
            }
        }
        let countryCode:String =  NSLocale.autoupdatingCurrentLocale().objectForKey(NSLocaleCountryCode) as! String
        return LocaleUtils.createLocaleFromCountryCode(countryCode)
    }
    
    func handleError(error : NSError!) {
        if (error != nil) {
            return
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if let locale = CelluarLocationManager.getCountryLocaleByCelluar() {
            self.promise!.success(locale)
        } else {
            "Fallback failed"
            self.promise!.failure(error)
        }
        
        println("Error getting current locale")
        println("Error: " + error.localizedDescription)
        locationManager.stopUpdatingLocation()
    }
}