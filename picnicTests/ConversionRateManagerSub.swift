
import Foundation

class ConversionRateManagerSub : ConversionRateManager {
    
    override func getConversionURL(homeCurrency: String, currentCurrency: String) -> NSURL? {
        let baseUrl = config!.valueForKey("api_url") as! String
        return NSURL(string: "\(baseUrl)/BITCOIN/FAKEGOLDCOIN")
    }
    
}