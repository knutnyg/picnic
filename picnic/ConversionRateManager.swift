
import Foundation


class ConversionRateManager : NSObject, NSURLConnectionDataDelegate, URLSessionDelegate{
    
    var statusCode:Int?
    var data:Data?
    var userModel:UserModel!
    var storedFileName = "data.dat"

    var configPath:String?
    internal var config:NSDictionary?

    init(userModel:UserModel){
        super.init()
        setConfigPath()
        config = self.loadConfig()
        self.userModel = userModel
    }
    
    func setConfigPath(){
        configPath = Bundle.main.path(forResource: "config", ofType: "plist")
    }
    
    func updateAllCurrencies(_ success: ((Bool) -> Void)? = nil){
        
        
//        // Fix to trust self signed certificate
//        let configuration = URLSessionConfiguration.default
//        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
//        
//        let URL = getAllCurrenciesURL()!
//        let request = URLRequest(url: URL)
//        
//        let task = session.dataTask(with: request, completionHandler: {
//            (data:Data?, response:URLResponse?, error:NSError?) in
//                print(response)
//                self.handleHTTPResponse(response, data: data, error: error)
//            } as! (Data?, URLResponse?, Error?) -> Void)
//        task.resume()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    
    
    func handleHTTPResponse(_ response:URLResponse?, data:Data?, error:NSError?){
        if error != nil {
            print("Got error: \(error)")
            self.userModel.updateingAllCurrenciesCounter = 0
            return
        }
        
        if let dat = data {
            if let json = parseRawJSONToDict(dat) {
                print (json)
                if let offlineEntries = parseJSONDictToOfflineEntries(json){
                    storeOfflineEntries(offlineEntries)
                    userModel.updateOfflineData(offlineEntries)
                }
            }
        }
        self.userModel.updateingAllCurrenciesCounter = 0
    }
    
    fileprivate func storeOfflineEntries(_ offlineEntries:[String:OfflineEntry]){
        if offlineEntries.count > 0 {
            saveDictionaryToDisk(self.storedFileName, dict: offlineEntries)
        }
    }

    fileprivate func parseRawJSONToDict(_ data:Data) -> Dictionary<String,Dictionary<String,String>>?{
        do {
            let json:Any = try JSONSerialization.jsonObject(with: data, options: [])
            if let dict = json as? Dictionary<String,AnyObject>{
                if let currenciesDict = dict["currencies"] as? Dictionary<String,Dictionary<String,String>> {
                    return currenciesDict
                }
            }
        } catch {
            print("Error: parsing JSON")
        }
        print("Error: Failed to parse JSON")
        return nil
    }
    
    fileprivate func parseJSONDictToOfflineEntries(_ dict:Dictionary<String, Dictionary<String,String>>) -> [String:OfflineEntry]?{
        var resultDict:[String:OfflineEntry] = [:]
        
        for key in dict.keys {
            let value = (dict[key]!["value"]! as NSString).doubleValue
            let from = dict[key]!["unit_from"]!
            let to = dict[key]!["unit_to"]!
            let timestamp = dict[key]!["timestamp"]!
            
            resultDict[key] = OfflineEntry(timeStamp: dateFromUTCString(timestamp), unit_from: from, unit_to: to, value: value)
        }
        return resultDict
    }
    
    func getConversionURL(_ homeCurrency:String, currentCurrency:String) -> URL?{
        if let conf = config {
            let url: String? = conf.value(forKey: "api_url") as? String
            if let baseurl = url {
                return URL(string: "\(baseurl)exchange/\(homeCurrency)/\(currentCurrency)")
            }
        }
        print("Error creating url from properties")
        return nil
    }
    
    func getAllCurrenciesURL() -> URL?{
        if let conf = config {
            let url: String? = conf.value(forKey: "api_url") as? String
            if let baseurl = url {
                return URL(string: "\(baseurl)currencies")
            }
        }
        print("Error creating url from properties")
        return nil
    }
    
    internal func loadConfig() -> NSDictionary?{
        if let path = configPath {
            return NSDictionary(contentsOfFile: path)
        } else {
            print("Error loading config")
        }
        return nil
    }
}
