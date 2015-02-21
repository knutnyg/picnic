
import Foundation
import CoreLocation

class LocationManagerWrapper : NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var country: String?
    
    override init() {
        super.init()
        setup()
        
    }
    
    func setup(){
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func start() {
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                println("Error: " + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm : CLPlacemark = placemarks[0] as CLPlacemark
                
                println("Received country by gps: \(pm.country)")
                self.country = pm.country
                self.locationManager.stopUpdatingLocation()
                
                
            } else {
                println("Error with the data.")
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {



        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }
}