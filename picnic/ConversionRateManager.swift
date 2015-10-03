
import Foundation


class ConversionRateManager : NSObject, NSURLConnectionDataDelegate, NSURLSessionDelegate{
    
    var statusCode:Int?
    var data:NSData?
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
        configPath = NSBundle.mainBundle().pathForResource("config", ofType: "plist")
    }
    
    func updateAllCurrencies(success: ((Bool) -> Void)? = nil){
        
        
        // Fix to trust self signed certificate
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        let URL = getAllCurrenciesURL()!
        let request = NSURLRequest(URL: URL)
        
        let task = session.dataTaskWithRequest(request){
            (data:NSData?, response:NSURLResponse?, error:NSError?) in
                print(response)
                self.handleHTTPResponse(response, data: data, error: error)
            }
        task.resume()
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
    
    
    func handleHTTPResponse(response:NSURLResponse?, data:NSData?, error:NSError?){
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
    
    private func storeOfflineEntries(offlineEntries:[String:OfflineEntry]){
        if offlineEntries.count > 0 {
            saveDictionaryToDisk(self.storedFileName, dict: offlineEntries)
        }
    }

    private func parseRawJSONToDict(data:NSData) -> Dictionary<String,Dictionary<String,String>>?{
        do {
            let json:AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
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
    
    private func parseJSONDictToOfflineEntries(dict:Dictionary<String, Dictionary<String,String>>) -> [String:OfflineEntry]?{
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
    
    func getConversionURL(homeCurrency:String, currentCurrency:String) -> NSURL?{
        if let conf = config {
            let url: String? = conf.valueForKey("api_url") as? String
            if let baseurl = url {
                return NSURL(string: "\(baseurl)exchange/\(homeCurrency)/\(currentCurrency)")
            }
        }
        print("Error creating url from properties")
        return nil
    }
    
    func getAllCurrenciesURL() -> NSURL?{
        if let conf = config {
            let url: String? = conf.valueForKey("api_url") as? String
            if let baseurl = url {
                return NSURL(string: "\(baseurl)currencies")
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