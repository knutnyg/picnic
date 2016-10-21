
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if shouldReportNextLocale {
            handleLocationUpdate(locations)
        }
    }
    
    internal func handleLocationUpdate(_ locations:[AnyObject]){
        shouldReportNextLocale = false
        let loc = locations[0] as! CLLocation
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler:
                {
                    (placemarks, error)->Void in
                    if error != nil {
                        self.handleError(error as NSError!)
                    } else {
                        self.handleLocation(placemarks!)
                    }
                }
            )
    }
    
    func handleLocation(_ placemarks: [AnyObject]) {
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
    
    internal func getLocaleFromPlacemark(_ placemarks:[AnyObject]) -> Locale{
        let a:CLPlacemark = placemarks.first as! CLPlacemark
        return LocaleUtils.createLocaleFromCountryCode(a.isoCountryCode! as NSString)
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
        userModel.updateHomeLocale(LocaleUtils.createLocaleFromCountryCode(countryCode as NSString))

    }
    
    fileprivate func getCountryCodeFromDevice() -> String{
        return (Locale.autoupdatingCurrent as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
    }
    
    func handleError(_ error : NSError!) {
        //This error is usually bad data preceeding good data. So we just skip it.
        print(error)
        userModel.updatingCurrentLocaleCounter = 0
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: " + error.localizedDescription)
        userModel.updatingCurrentLocaleCounter = 0
    }
}
