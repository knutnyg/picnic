
import Foundation
import CoreLocation
import BrightFutures


class LocationManager : NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var promise:Promise<NSLocale>?
    
    var overrideGPSLocale:NSLocale?
    var shouldOverrideGPS = false
    
    var overrideLogicalLocale:NSLocale?
    var shouldOverrideLogical = false
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "overrideGPSLocaleChanged:", name: "overrideGPSLocaleChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "overrideLogicalLocaleChanged:", name: "overrideLogicalLocaleChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shouldOverrideGPSChanged:", name: "shouldOverrideGPSChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shouldOverrideLogicalChanged:", name: "shouldOverrideLogicalChanged", object: nil)
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
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
        if self.shouldOverrideGPS {
            if let override = self.overrideGPSLocale {
                println("locationmanager returning overrided GPS locale")
                println(LocaleUtils.createCountryNameFromLocale(override))
                return override
            }
        }
        return nil
    }
    
    func returnOverridedLogicalLocationIfSet() -> NSLocale?{
        if self.shouldOverrideLogical {
            if let override = self.overrideLogicalLocale {
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
        self.overrideGPSLocale = notification.object as? NSLocale
    }
    
    func overrideLogicalLocaleChanged(notification:NSNotification){
        self.overrideLogicalLocale = notification.object as? NSLocale
    }
    
    func shouldOverrideGPSChanged(notification:NSNotification){
        self.shouldOverrideGPS = notification.object as Bool
    }
    
    func shouldOverrideLogicalChanged(notification:NSNotification){
        self.shouldOverrideLogical = notification.object as Bool
    }
    
}