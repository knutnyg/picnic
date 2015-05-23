
import Foundation
import CoreLocation
import CoreTelephony


class GPSLocationManager : NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
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
            userModel.updateCurrentLocale(locale)
            userModel.updatingCurrentLocaleCounter = 0
            stopMonitoringGPS()
        }
        println("done handler")
    }
    
    internal func getLocaleFromPlacemark(placemarks:[AnyObject]) -> NSLocale{
        let pm:CLPlacemark = placemarks.first as! CLPlacemark
        return LocaleUtils.createLocaleFromCountryCode(pm.ISOcountryCode)
    }

    func updateUserCurrentLocale() {
        if userModel.shouldOverrideGPS {
            userModel.updatingCurrentLocaleCounter = 0
            return
        }
        startMonitoringGPS()
    }
    
    func updateUserHomeLocale() {
        userModel.updatingHomeLocaleCounter = 0
        if userModel.shouldOverrideLogical {
            return
        }
        let countryCode:String =  getCountryCodeFromDevice()
        userModel.updateHomeLocale(LocaleUtils.createLocaleFromCountryCode(countryCode))

    }
    
    private func getCountryCodeFromDevice() -> String{
        return NSLocale.autoupdatingCurrentLocale().objectForKey(NSLocaleCountryCode) as! String
    }

    
    internal func startMonitoringGPS(){
        locationManager.startUpdatingLocation()
    }
    
    internal func stopMonitoringGPS(){
        locationManager.stopUpdatingLocation()
    }
    
    
    func handleError(error : NSError!) {
        //This error is usually bad data preceeding good data. So we just skip it.
        println(error)
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
        locationManager.stopUpdatingLocation()
        userModel.updatingCurrentLocaleCounter = 0
    }
}