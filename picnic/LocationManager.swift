
import Foundation
import CoreLocation
import BrightFutures


class LocationManager : NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var promise:Promise<NSLocale>?
    var userModel:UserModel!
    
    init(userModel:UserModel) {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "overrideGPSLocaleChanged:", name: "overrideGPSLocaleChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "overrideLogicalLocaleChanged:", name: "overrideLogicalLocaleChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shouldOverrideGPSChanged:", name: "shouldOverrideGPSChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shouldOverrideLogicalChanged:", name: "shouldOverrideLogicalChanged", object: nil)
        
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
            locationManager.stopUpdatingLocation()

        }
    }    

    func getUserCurrentLocale() -> Future<NSLocale> {
        self.promise = Promise<NSLocale>()

        if let override = self.returnOverridedGPSLocationIfSet() {
            println("overrideing GPS")
            self.promise!.success(override)
            return promise!.future
        }
        
        self.locationManager.startUpdatingLocation()
        return self.promise!.future
    }
    
    
    func getUserHomeLocale() -> NSLocale {
        if let override = self.returnOverridedLogicalLocationIfSet() {
            return override
        }
        
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
        println("Error: " + error.localizedDescription)
    }
    
    func overrideGPSLocaleChanged(notification:NSNotification){
        userModel.overrideGPSLocale = notification.object as? NSLocale
        println("LocationManager: Got GPS override")
    }
    
    func overrideLogicalLocaleChanged(notification:NSNotification){
        userModel.overrideLogicalLocale = notification.object as? NSLocale
        println("LocationManager: Got Logical override")
    }
    
    func shouldOverrideGPSChanged(notification:NSNotification){
        userModel.shouldOverrideGPS = notification.object as Bool
        println("LocationManager: Got should override GPS: \(notification.object)")
    }
    
    func shouldOverrideLogicalChanged(notification:NSNotification){
        userModel.shouldOverrideLogical = notification.object as Bool
        println("LocationManager: Got should override Logical: \(notification.object)")
    }
    
}