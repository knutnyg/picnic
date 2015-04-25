
import Foundation
import CoreLocation
import BrightFutures

class GPSLocationManagerSub : GPSLocationManager{

    var shouldFail:Bool = false
    var noPlacemarks = [CLPlacemark()]
    
    var dummyManager = CLLocationManager()
    
    override init(userModel:UserModel){
        super.init(userModel: userModel)
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
    }
    
    override func handleLocationUpdate(manager: CLLocationManager) {
        if shouldFail {
            promise!.failure(NSError(domain: "GPS FAILURE", code: 500, userInfo: nil))
        } else {
            handleLocation(noPlacemarks)
        }
    }
    
    override func getLocaleFromPlacemark(placemarks: [AnyObject]) -> NSLocale {
        return NSLocale(localeIdentifier: "en_GB")
    }
    
    override func getUserCurrentLocale() -> Future<NSLocale> {
        if shouldFail {
            return Future.failed(NSError(domain: "GPS FAILURE", code: 500, userInfo: nil))
        } else {
            return Future.succeeded(NSLocale(localeIdentifier: "en_GB"))
        }
    }
    
    override func startMonitoringGPS() {
        delay(0.2, {self.handleLocationUpdate(self.dummyManager)})
    }
    
    override func stopMonitoringGPS() {
        //
    }
}






    