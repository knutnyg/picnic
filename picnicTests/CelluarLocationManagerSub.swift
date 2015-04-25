
import Foundation

class CelluarLocationManagerSub : CelluarLocationManager {
    
    var shouldFail = false
    
    override func getCountryCodeFromSim() -> String? {
        if shouldFail {
            return nil
        } else {
            return "NO"
        }
    }
}