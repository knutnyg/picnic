
import Foundation
import SwiftHTTP
import BrightFutures
import JSONJoy


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
    
    func updateAllCurrencies() -> Promise<String, NSError>{

        let URL = getAllCurrenciesURL()!.absoluteString
        let promise = Promise<String, NSError>()

        do {
            let request = try HTTP.GET(URL)

            request.start {
                (response:Response) in
                if let err = response.error {
                    print("PicnicAPI: Response contains error: \(err)")
                    promise.failure(err)
                    return
                }

                if let json = self.parseRawJSONToDict(response.data) {
                        print (json)
                        if let offlineEntries = self.parseJSONDictToOfflineEntries(json){
                            self.storeOfflineEntries(offlineEntries)
                            self.userModel.updateOfflineData(offlineEntries)
                        }
                }

                self.userModel.updateingAllCurrenciesCounter = 0

                return promise.success("yey")
            }
        } catch {
            print("Unexpected error in PicnicAPI")
        }
            return promise

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
    
    func storeOfflineEntries(_ offlineEntries:[String:OfflineEntry]){
        if offlineEntries.count > 0 {
            saveDictionaryToDisk(self.storedFileName, dict: offlineEntries)
        }
    }

    func parseRawJSONToDict(_ data:Data) -> Dictionary<String,Dictionary<String,String>>?{
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
    
    func parseJSONDictToOfflineEntries(_ dict:Dictionary<String, Dictionary<String,String>>) -> [String:OfflineEntry]?{
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

//struct Currencies : JSONJoy {
//    let currencies: [String:Currency]
//
//    init(_ decoder: JSONDecoder) {
//        let curs = try! decoder["currencies"].dictionary!
//        var collect = [String:Currency]()
//        for curDecoder in curs {
//            collect.append(Currency(curDecoder))
//        }
//        currencies = collect
//    }
//}
//
//struct Entry: JSONJoy {
//    let key:String
//    let currency:Currency
//
//    init(_ decoder: JSONDecoder) {
//        key =
//    }
//}
//
//
//
//struct Currency: JSONJoy {
//    let timestamp: String
//    let unit_from: String
//    let unit_to: String
//    let value: Double
//
//    init(_ decoder: JSONDecoder) {
//        timestamp = try! decoder["timestamp"].getString()
//        unit_from = try! decoder["unit_from"].getString()
//        unit_to = try! decoder["unit_to"].getString()
//        value = try! decoder["value"].getDouble()
//    }
//}