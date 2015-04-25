
import Foundation

class LocationManagerSub : LocationManager {
    
    override init(userModel: UserModel){
        super.init(userModel: userModel)
        self.gpsLocationManager = GPSLocationManagerSub(userModel: userModel)
        self.celluarLocationManager = CelluarLocationManagerSub()
    }
 
    override internal func getCountryCodeFromDevice() -> String{
        return "NO"
    }
}