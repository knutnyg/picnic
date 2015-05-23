
import Foundation
import SwiftHTTP


class ConversionRateManager : NSObject, NSURLConnectionDataDelegate{
    
    var statusCode:Int?
    var data:NSData?
    var userModel:UserModel!

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
        let request = HTTPTask()
        request.requestSerializer = HTTPRequestSerializer()
        request.responseSerializer = JSONResponseSerializer()
        
        request.GET(URL.description, parameters: nil,
            success:
            {(response: HTTPResponse) in
                if response.responseObject != nil {
                    if let dict = response.responseObject as? Dictionary<String,AnyObject> {
                        var offlineEntries = self.parseResult(dict as! Dictionary<String, Dictionary<String, String>>)
                        self.userModel.offlineData = offlineEntries
                        saveDictionaryToDisk("data.dat", offlineEntries)
                        self.userModel.updateingAllCurrenciesCounter -= 1
                        if let callback = success {
                            callback(true)
                        }
                    }
                } else {
                    println("Failed to parse response from server")
                    if let callback = success {
                        callback(false)
                    }
                }
            },
            failure:
            {(error: NSError, response: HTTPResponse?) in
                        println("Got error: \(error)")
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
    
    func getConversionRateFromResponse(data: NSData) -> Double? {
        
        if let json: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) {
            let dictionary = json as! NSDictionary
            var value = dictionary.valueForKey("value")!.doubleValue
            if value > 0 {
                return value
            }
        }
        return nil
    }
}