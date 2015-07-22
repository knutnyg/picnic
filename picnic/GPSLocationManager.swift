
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
    
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.requestWhenInUseAuthorization()
        self.userModel = userModel
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if shouldReportNextLocale {
            handleLocationUpdate(locations)
        }
    }
    
    internal func handleLocationUpdate(locations:[AnyObject]){
        shouldReportNextLocale = false
        var loc = locations[0] as! CLLocation
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler:
                {
                    (placemarks, error)->Void in
                    if error != nil {
                        self.handleError(error)
                    } else {
                        self.handleLocation(placemarks!)
                    }
                }
            )
    }
    
    func handleLocation(placemarks: [AnyObject]) {
        if placemarks.isEmpty {
            print("Error with the data.")
        } else {
            let locale = getLocaleFromPlacemark(placemarks)
            print("Updating current locale: \(LocaleUtils.createCountryNameFromLocale(locale, languageLocale: nil))")
            userModel.updateCurrentLocale(locale)
            shouldReportNextLocale = false
            userModel.updatingCurrentLocaleCounter = 0
            
           locationManager.stopUpdatingLocation()

        }
    }
    
    internal func getLocaleFromPlacemark(placemarks:[AnyObject]) -> NSLocale{
        let pm:CLPlacemark = placemarks.first as! CLPlacemark
        return LocaleUtils.createLocaleFromCountryCode(pm.ISOcountryCode!)
    }

    func updateUserCurrentLocale() {
        if userModel.overrideGPSLocale != nil {
            userModel.updatingCurrentLocaleCounter = 0
            return
        }
        
        shouldReportNextLocale = true
        locationManager.startUpdatingLocation()

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
        print(error)
        userModel.updatingCurrentLocaleCounter = 0
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
        userModel.updatingCurrentLocaleCounter = 0
    }
}