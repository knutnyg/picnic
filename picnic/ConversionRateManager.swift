
import BrightFutures
import Foundation


class ConvertsionRateManager : NSObject, NSURLConnectionDataDelegate{
    
    var statusCode:Int?
    var data:NSData?
    
    let HTTP_OK:Int = 200
    let HTTP_SERVER_ERROR:Int = 503
    var promise:Promise<Double>!
    
    func getConvertionRate(userModel:UserModel) -> Future<Double> {
        
        promise = Promise<Double>()
        
        if let homeLocale = userModel.homeLocale,  currentLocale = userModel.currentLocale {
            let homeCurrency = homeLocale.objectForKey(NSLocaleCurrencyCode) as! String
            let currentCurrency = currentLocale.objectForKey(NSLocaleCurrencyCode) as! String
            
            let urlString = "http://picnic.logisk.org/api/exchange/\(homeCurrency)/\(currentCurrency)"

            let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            request.timeoutInterval = 15
            
            var connection:NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
            }

        return promise.future
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.data = data
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        var err: NSError
        
        if let status = self.statusCode , data = self.data {
            if status ==  HTTP_OK {
                var dataAsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
                var conversionRate : Double = dataAsDictionary.objectForKey("value")!.doubleValue;
                self.promise.success(conversionRate)
            } else {
                self.promise.failure(NSError(domain: "HTTP_STATUS_CODE", code: 503, userInfo: nil))
            }
        } else {
            self.promise.failure(NSError(domain: "RESPONSE_CONTAINED_NIL", code: 0, userInfo: nil))
        }
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