
import Foundation


class ConversionRateManager : NSObject, NSURLConnectionDataDelegate{
    
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
        
        let URL = getAllCurrenciesURL()!
        let request = NSURLRequest(URL: URL)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){
            (data:NSData?, response:NSURLResponse?, error:NSError?) in
                self.handleHTTPResponse(response, data: data, error: error)
            }
        if let t = task {
            t.resume()
        }
    }

    func handleHTTPResponse(response:NSURLResponse?, data:NSData?, error:NSError?){
        if error != nil {
            print("Got error: \(error)")
            self.userModel.updateingAllCurrenciesCounter = 0
            return
        }
        
        if let dat = data {
            if let json = parseRawJSONToDict(dat) {
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
        var jsonError: NSError?
        do {
            let json: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            if let dict = json as? Dictionary<String,Dictionary<String, String>>{
                return dict
            }
        } catch let error as NSError {
            jsonError = error
            print("Error: \(jsonError)")
        }
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
    
    func getFileURL(fileName: String) -> NSURL {
        let manager = NSFileManager.defaultManager()
        let dirURL: NSURL?
        do {
            dirURL = try manager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        } catch _ {
            dirURL = nil
        }
        return dirURL!.URLByAppendingPathComponent(fileName)
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