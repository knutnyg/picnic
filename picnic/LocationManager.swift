
import Foundation
import CoreLocation
import BrightFutures


class LocationManager : NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var promise:Promise<NSLocale>?
    var userModel:UserModel!
    
    init(userModel:UserModel) {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.userModel = userModel
    }
    
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler:
            {
                (placemarks, error)->Void in

                if error != nil {
                    self.handleError(error)
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
            let pm:CLPlacemark = placemarks.first as CLPlacemark
            let locale:NSLocale = LocaleUtils.createLocaleFromCountryCode(pm.ISOcountryCode)
            self.promise!.success(locale)
            println("returning current location")
            locationManager.stopUpdatingLocation()
        }
    }    

    func getUserCurrentLocale() -> Future<NSLocale> {
        self.promise = Promise<NSLocale>()

        println("getting current locale")
        if let override = self.returnOverridedGPSLocationIfSet() {
            println("overrideing GPS")
            self.promise!.success(override)
            return promise!.future
        }
        
        self.locationManager.startUpdatingLocation()
        return self.promise!.future
    }
    
//    func startTimeoutCounter(){
//        NSTimer(timeInterval: 3, target: self, selector: Selector("timeout"), userInfo: nil, repeats: false)
//    }
//    
//    func timeout(){
//        println("timeout!")
//        self.promise?.failure(NSError())
//    }
    
    func getUserHomeLocale() -> NSLocale {
        if let override = self.returnOverridedLogicalLocationIfSet() {
            println("returning override")
            return override
        }
        println("returning real home country")
        let countryCode:String =  NSLocale.autoupdatingCurrentLocale().objectForKey(NSLocaleCountryCode) as String
        return LocaleUtils.createLocaleFromCountryCode(countryCode)
    }
    
    func handleError(error : NSError!) {
        if (error != nil) {
            return
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        self.promise!.failure(error)
        println("Error getting current locale")
        println("Error: " + error.localizedDescription)
    }
}