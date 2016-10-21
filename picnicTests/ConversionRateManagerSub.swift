
import Foundation

class ConversionRateManagerSub : ConversionRateManager {
    
    override func getConversionURL(_ homeCurrency: String, currentCurrency: String) -> URL? {
        let baseUrl = config!.value(forKey: "api_url") as! String
        return URL(string: "\(baseUrl)/BITCOIN/FAKEGOLDCOIN")
    }
    
}
