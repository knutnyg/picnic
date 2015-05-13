
import BrightFutures
import Foundation
import SwiftHTTP


class ConversionRateManager : NSObject, NSURLConnectionDataDelegate{
    
    var statusCode:Int?
    var data:NSData?
    var promiseInProgress:Bool = false

    var configPath:String?
    internal var config:NSDictionary?

    override init(){
        super.init()
        setConfigPath()
        config = self.loadConfig()
    }
    
    func setConfigPath(){
        configPath = NSBundle.mainBundle().pathForResource("config", ofType: "plist")
    }
    
    func getConvertionRate(userModel:UserModel) -> Future<ConversionRateObject> {
        var conversionRatePromise = Promise<ConversionRateObject>()
        
        if let homeLocale = userModel.homeLocale,  currentLocale = userModel.currentLocale {
            let homeCurrency = homeLocale.objectForKey(NSLocaleCurrencyCode) as! String
            let currentCurrency = currentLocale.objectForKey(NSLocaleCurrencyCode) as! String
            
            if let URL = getConversionURL(homeCurrency, currentCurrency: currentCurrency){
                let request = HTTPTask()
                request.requestSerializer = HTTPRequestSerializer()
                request.responseSerializer = JSONResponseSerializer()
                
                request.GET(URL.description, parameters: nil,
                    success: {
                        (response: HTTPResponse) in
                        
                        if response.responseObject != nil {
                            if let dict = response.responseObject as? Dictionary<String, AnyObject> {
                                println("returning conversion rate")
                                if let value = (dict["value"] as? NSString)?.doubleValue {
                                    var timeStamp = dateFromUTCString(dict["timestamp"] as! String)
                                    var convObj = ConversionRateObject(value: value, timestamp: timeStamp)
                                    
                                    conversionRatePromise.success(convObj)
                                    return
                                } else {
                                    println("response does not contain conversion rate")
                                }
                            } else {
                                println("unparseable response")
                            }
                        } else {
                            println("empty response")
                        }
                        
                        if let fallbackValue = self.getOfflineConversionRate(userModel, from: currentCurrency, to: homeCurrency) {
                            println("returning fallback conversion rate")
                            conversionRatePromise.success(fallbackValue)
                            return
                        } else {
                            conversionRatePromise.failure(NSError(domain: "Got errorinous response", code: 400, userInfo: nil))
                        }
                    },
                    failure: {(error: NSError, response: HTTPResponse?) in
                        
                        if let fallbackValue = self.getOfflineConversionRate(userModel, from: currentCurrency, to: homeCurrency) {
                            println("returning fallback conversion rate")
                            conversionRatePromise.success(fallbackValue)
                        } else {
                            conversionRatePromise.failure(error)
                        }
                })
            } else {
                conversionRatePromise.failure(NSError(domain: "failed to load url", code: 400, userInfo: nil))
            }
            
        } else {
            conversionRatePromise.failure(NSError(domain: "locales not set", code: 400, userInfo: nil))
        }
        return conversionRatePromise.future
    }
    
    func getOfflineConversionRate(userModel:UserModel, from:String,to:String) -> ConversionRateObject? {
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
    
    func getAllCurrencies() -> Future<NSDictionary> {
        var currenciesPromisee = Promise<NSDictionary>()
        
        let URL = getAllCurrenciesURL()!
        let request = HTTPTask()
        request.requestSerializer = HTTPRequestSerializer()
        request.responseSerializer = JSONResponseSerializer()
        
        request.GET(URL.description, parameters: nil,
            success:
            {(response: HTTPResponse) in
                if response.responseObject != nil {
                    if let dict = response.responseObject as? Dictionary<String,AnyObject> {
                        currenciesPromisee.success(dict)
                    }
                } else {
                        currenciesPromisee.failure(NSError(domain: "no data in response", code: 500, userInfo: nil))
                }
            },
            failure:
            {(error: NSError, response: HTTPResponse?) in
                currenciesPromisee.failure(error)
        })
        return currenciesPromisee.future
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
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}