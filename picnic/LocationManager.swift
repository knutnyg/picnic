
import Foundation
import CoreLocation
import BrightFutures


class LocationManager : NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let promise = Promise<NSLocale>()
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in

            self.handleError(error)
            self.handleLocation(placemarks)
            
            })
    }
    
    func handleLocation(placemarks: [AnyObject]) {
        if placemarks.isEmpty {
            println("Error with the data.")
        } else {
            let pm:CLPlacemark = placemarks.first as CLPlacemark
            let locale:NSLocale = self.createLocaleFromCountryCode(pm.ISOcountryCode)
            promise.success(locale)
            locationManager.stopUpdatingLocation()
            println("Received country by gps: \(pm.country)")

        }

    }
    
    func createLocaleFromCountryCode(countryCode:NSString) -> NSLocale {
        let userLanguageCode = NSBundle.mainBundle().preferredLocalizations.first as String
        println(userLanguageCode)
        
        var locale = NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents(NSDictionary(object: countryCode, forKey: NSLocaleCountryCode)))
        
        return locale
    }
    

    func getUserCurrentLocale() -> Future<NSLocale> {
        self.locationManager.startUpdatingLocation()
        return promise.future
    }
    
    func getUserHomeLocale() -> NSLocale {
        let countryCode:String =  NSLocale.autoupdatingCurrentLocale().objectForKey(NSLocaleCountryCode) as String
        
        return self.createLocaleFromCountryCode(countryCode)
    }
    
    func handleError(error : NSError!) {
        if (error != nil) {
            println("Error: " + error.localizedDescription)
            return
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        promise.failure(error)
        println("Error: " + error.localizedDescription)
    }
    
    
}