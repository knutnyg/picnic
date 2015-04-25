
import BrightFutures
import Foundation


class ConversionRateManager : NSObject, NSURLConnectionDataDelegate{
    
    var statusCode:Int?
    var data:NSData?
    
    let HTTP_OK:Int = 200
    let HTTP_SERVER_ERROR:Int = 503
    var promise:Promise<Double>!
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
        promise = Promise<Double>()
        
        if let homeLocale = userModel.homeLocale,  currentLocale = userModel.currentLocale {
            let homeCurrency = homeLocale.objectForKey(NSLocaleCurrencyCode) as! String
            let currentCurrency = currentLocale.objectForKey(NSLocaleCurrencyCode) as! String
            
            if let url = getURL(homeCurrency, currentCurrency: currentCurrency) {
                var request = NSMutableURLRequest(URL: url)
                request.timeoutInterval = 15
                var connection:NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
            } else {
                promise.failure(NSError(domain: "Error creaing URL", code: 500, userInfo: nil))
            }
        } else {
            promise.failure(NSError(domain: "Home and/or current locale not set!", code: 500, userInfo: nil))
        }
        return promise.future
    }
    
    func getURL(homeCurrency:String, currentCurrency:String) -> NSURL?{
        if let conf = config {
            var url: String? = conf.valueForKey("api_url") as? String
            if let baseurl = url {
                return NSURL(string: "\(baseurl)/\(homeCurrency)/\(currentCurrency)")
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
                self.promise.success(conversionRate)
            } else {
                self.promise.failure(NSError(domain: "HTTP", code: 400, userInfo: nil))
            }
        } else {
            self.promise.failure(NSError(domain: "RESPONSE_CONTAINED_NIL", code: 400, userInfo: nil))
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
        self.promise.failure(error)
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