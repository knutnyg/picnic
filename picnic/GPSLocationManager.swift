
import Foundation
import CoreLocation
import CoreTelephony


class GPSLocationManager : NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var userModel:UserModel!
    var lastLocation:CLLocation?
    var shouldReportNextLocale:Bool = false
    
    init(userModel:UserModel) {
        super.init()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.requestWhenInUseAuthorization()
        self.userModel = userModel
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
            handleLocationUpdate(manager)
    }
    
    internal func handleLocationUpdate(manager:CLLocationManager){
        if shouldReportNextLocale {
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
    }
    
    func handleLocation(placemarks: [AnyObject]) {
        if placemarks.isEmpty {
            println("Error with the data.")
        } else {
            let locale = getLocaleFromPlacemark(placemarks)
            println("Updating current locale: \(LocaleUtils.createCountryNameFromLocale(locale, languageLocale: nil))")
            userModel.updateCurrentLocale(locale)
            shouldReportNextLocale = false
            userModel.updatingCurrentLocaleCounter = 0
            locationManager.stopUpdatingLocation()
        }
    }
    
    internal func getLocaleFromPlacemark(placemarks:[AnyObject]) -> NSLocale{
        let pm:CLPlacemark = placemarks.first as! CLPlacemark
        return LocaleUtils.createLocaleFromCountryCode(pm.ISOcountryCode)
    }

    func updateUserCurrentLocale() {
        if userModel.overrideGPSLocale != nil {
            userModel.updatingCurrentLocaleCounter = 0
            return
        }
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
        shouldReportNextLocale = true
    }
    
    func updateUserHomeLocale() {
        userModel.updatingHomeLocaleCounter = 0
        if userModel.overrideLogicalLocale != nil {
            return
        }
        let countryCode:String =  getCountryCodeFromDevice()
        userModel.updateHomeLocale(LocaleUtils.createLocaleFromCountryCode(countryCode))

    }
    
    private func getCountryCodeFromDevice() -> String{
        return NSLocale.autoupdatingCurrentLocale().objectForKey(NSLocaleCountryCode) as! String
    }
    
    func handleError(error : NSError!) {
        //This error is usually bad data preceeding good data. So we just skip it.
        println(error)
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }
}