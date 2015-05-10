
import Foundation
import CoreLocation
import BrightFutures
import CoreTelephony


class GPSLocationManager : NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var promise:Promise<NSLocale>?
    var promiseInProgress:Bool = false
    var userModel:UserModel!
    
    init(userModel:UserModel) {
        super.init()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.requestWhenInUseAuthorization()
        self.userModel = userModel
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
            handleLocationUpdate(manager)
    }
    
    internal func handleLocationUpdate(manager:CLLocationManager){
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler:
            {
                (placemarks, error)->Void in
                
                println("got response")
                if error != nil {
                    self.handleError(error)
                    self.stopMonitoringGPS()
                } else {
                    self.handleLocation(placemarks)

                }
            }
        )

    }
    
    func handleLocation(placemarks: [AnyObject]) {
        if placemarks.isEmpty {
            println("Error with the data.")
        } else {
            
            let locale = getLocaleFromPlacemark(placemarks)
            
            if(promiseInProgress){
                self.promise!.success(locale)
                promiseInProgress = false
            }
            stopMonitoringGPS()
        }
        println("done handler")
    }
    
    internal func getLocaleFromPlacemark(placemarks:[AnyObject]) -> NSLocale{
        let pm:CLPlacemark = placemarks.first as! CLPlacemark
        return LocaleUtils.createLocaleFromCountryCode(pm.ISOcountryCode)
    }

    func getUserCurrentLocale() -> Future<NSLocale> {
        self.promise = Promise<NSLocale>()
        self.promiseInProgress = true

        startMonitoringGPS()
        return self.promise!.future
    }
    
    internal func startMonitoringGPS(){
        locationManager.startUpdatingLocation()
    }
    
    internal func stopMonitoringGPS(){
        locationManager.stopUpdatingLocation()
    }
    
        
    func handleError(error : NSError!) {
        self.promise?.failure(error)
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        self.promise!.failure(error)
        println("Error: " + error.localizedDescription)
        stopMonitoringGPS()
    }
}