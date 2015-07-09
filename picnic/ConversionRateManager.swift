
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
    
    func getOfflineConversionRate(from:String,to:String) -> ConversionRateObject? {
        if let data = userModel.offlineData {
            var fromVal = data[from]?.value
            var toVal = data[to]?.value
            var timestamp = data[from]?.timeStamp
            
            if let from = fromVal, to = toVal, ts = timestamp {
                return ConversionRateObject(value: (from/to),timestamp: ts)
            }
        }
        return nil
    }
    
    func updateAllCurrencies(success: ((Bool) -> Void)? = nil){
        
        let URL = getAllCurrenciesURL()!
        var jsonError: NSError?
        
        let request = NSURLRequest(URL: URL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response, data, error) in
            
            if error != nil {
                self.userModel.updateingAllCurrenciesCounter = 0
                println("Got error: \(error)")
            } else {
                if let json: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError){
                    if let dict = json as? Dictionary<String,Dictionary<String, String>>{
                        var offlineEntries = self.parseResult(dict)
                        self.userModel.offlineData = offlineEntries
                        saveDictionaryToDisk(self.storedFileName, offlineEntries)
                        self.userModel.updateingAllCurrenciesCounter = 0
                        if let callback = success {
                            callback(true)
                        }
                    }
                }
            }
        })
    }
    
    private func parseResult(dict:Dictionary<String, Dictionary<String,String>>) -> [String:OfflineEntry]{
        var resultDict:[String:OfflineEntry] = [:]
        
        for key in dict.keys {
            var value = (dict[key]!["value"]! as NSString).doubleValue
            var from = dict[key]!["unit_from"]!
            var to = dict[key]!["unit_to"]!
            var timestamp = dict[key]!["timestamp"]!
            
            resultDict[key] = OfflineEntry(timeStamp: dateFromUTCString(timestamp), unit_from: from, unit_to: to, value: value)
        }
        return resultDict
    }
    
    func getFileURL(fileName: String) -> NSURL {
        let manager = NSFileManager.defaultManager()
        let dirURL = manager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false, error: nil)
        return dirURL!.URLByAppendingPathComponent(fileName)
    }
    
    func getConversionURL(homeCurrency:String, currentCurrency:String) -> NSURL?{
        if let conf = config {
            var url: String? = conf.valueForKey("api_url") as? String
            if let baseurl = url {
                return NSURL(string: "\(baseurl)exchange/\(homeCurrency)/\(currentCurrency)")
            }
        }
        println("Error creating url from properties")
        return nil
    }
    
    func getAllCurrenciesURL() -> NSURL?{
        if let conf = config {
            var url: String? = conf.valueForKey("api_url") as? String
            if let baseurl = url {
                return NSURL(string: "\(baseurl)currencies")
            }
        }
        println("Error creating url from properties")
        return nil
    }
    
    internal func loadConfig() -> NSDictionary?{
        if let path = configPath {
            return NSDictionary(contentsOfFile: path)
        } else {
            println("Error loading config")
        }
        return nil
    }
}