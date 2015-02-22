
import Foundation
import CoreLocation
import BrightFutures

class LocationManagerWrapper : NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let promise = Promise<String>()
    
    override init() {
        super.init()
        setup()
    }
    
    func setup(){
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
            promise.success(pm.country)
            locationManager.stopUpdatingLocation()
            println("Received country by gps: \(pm.country)")
        }

    }
    
    func getCountry() -> Future<String> {
        self.locationManager.startUpdatingLocation()
        return promise.future
    }
    
    func handleError(error : NSError!) {
        if (error != nil) {
            println("Error: " + error.localizedDescription)
            return
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }
    
    
}