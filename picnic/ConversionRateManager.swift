
import BrightFutures
import Foundation
import SwiftHTTP
import JSONJoy


class ConversionRateManager : NSObject, NSURLConnectionDataDelegate{
    
    var statusCode:Int?
    var data:NSData?
    
    let HTTP_OK:Int = 200
    let HTTP_SERVER_ERROR:Int = 503
    var conversionRatePromise:Promise<Double>!
    var currenciesPromise:Promise<NSDictionary>!
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
    
    func getConvertionRate(userModel:UserModel) -> Future<Double> {
        conversionRatePromise = Promise<Double>()
        
        if let homeLocale = userModel.homeLocale,  currentLocale = userModel.currentLocale {
            let homeCurrency = homeLocale.objectForKey(NSLocaleCurrencyCode) as! String
            let currentCurrency = currentLocale.objectForKey(NSLocaleCurrencyCode) as! String
            
            if(userModel.offlineMode){
                if let data = userModel.offlineData {
                    var valueFrom = data[currentCurrency]?.value
                    var valueTo = data[homeCurrency]?.value
                    
                    println("using offline data:")
                    println("converting from: \(currentCurrency) to \(homeCurrency) with convrate: \(valueFrom!/valueTo!)")
                    
                    return Future.succeeded(valueFrom!/valueTo!)
                }

            }
            
            if let url = getConversionURL(homeCurrency, currentCurrency: currentCurrency) {
                println(url)
                var request = NSMutableURLRequest(URL: url)
                request.timeoutInterval = 15
                var connection:NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
            } else {
                conversionRatePromise.failure(NSError(domain: "Error creaing URL", code: 500, userInfo: nil))
            }
        } else {
            conversionRatePromise.failure(NSError(domain: "Home and/or current locale not set!", code: 500, userInfo: nil))
        }
        return conversionRatePromise.future
    }
    
    func getAllCurrencies() -> Future<NSDictionary> {
        currenciesPromise = Promise<NSDictionary>()
        
        let URL = getAllCurrenciesURL()!
        let request = HTTPTask()
        request.requestSerializer = HTTPRequestSerializer()
        request.responseSerializer = JSONResponseSerializer()
        
        request.GET(URL.description, parameters: nil,
            success:
            {(response: HTTPResponse) in
                if response.responseObject != nil {
                    if let dict = response.responseObject as? Dictionary<String,AnyObject> {
                        self.currenciesPromise.success(dict)
                    }
                } else {
                    self.currenciesPromise.failure(NSError(domain: "no data in response", code: 500, userInfo: nil))
                }
            },
            failure:
            {(error: NSError, response: HTTPResponse?) in
                self.currenciesPromise.failure(error)
        })
        return currenciesPromise.future
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
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.data = data
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        var err: NSError
        
        if let status = self.statusCode , data = self.data, conversionRate = getConversionRateFromResponse(data) {
            if status ==  HTTP_OK {
                self.conversionRatePromise.success(conversionRate)
            } else {
                self.conversionRatePromise.failure(NSError(domain: "HTTP", code: 400, userInfo: nil))
            }
        } else {
            self.conversionRatePromise.failure(NSError(domain: "RESPONSE_CONTAINED_NIL", code: 400, userInfo: nil))
        }
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
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.statusCode = response.valueForKey("statusCode") as? Int
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("TIMEOUT")
        self.conversionRatePromise.failure(error)
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