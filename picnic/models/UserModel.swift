
import Foundation
import StoreKit

 class UserModel : NSObject, SKProductsRequestDelegate {
    
    var observers:[UserModelObserver]
    var languageLocale:Locale!
    var homeLocale:Locale!
    var currentLocale:Locale!
    var homeAmount:Double?
    var currentAmount:Double?
    var priceString:String?
    var removeAdProduct:SKProduct?
    
    var overrideGPSLocale:Locale? {
        didSet {
            UserDefaults.standard.setValue(overrideGPSLocale?.identifier, forKey: "overrideGPSLocale")
            UserDefaults.standard.synchronize()
        }
    }
    
    var overrideLogicalLocale:Locale? {
        didSet {
            UserDefaults.standard.setValue(overrideLogicalLocale?.identifier, forKey: "overrideLogicalLocale")
            UserDefaults.standard.synchronize()
        }
    }
    
    var skipAds:Bool {
        didSet {
            UserDefaults.standard.set(skipAds, forKey: "skipAds")
            UserDefaults.standard.synchronize()
        }
    }

    var offlineMode:Bool = false
    var offlineData:Dictionary<String,OfflineEntry>?
    
    var updatingHomeLocaleCounter:Int = 0
    var updatingCurrentLocaleCounter:Int = 0
    var updateingAllCurrenciesCounter:Int = 0
    
    override init(){
        self.observers = []
        self.homeLocale = Locale(identifier: "en_US")
        self.currentLocale = Locale(identifier: "en_US")

        self.skipAds = UserDefaults.standard.bool(forKey: "skipAds")
        
        super.init()
        self.setupUserLanguageLocale()
        requestProducts()
    }
    
    func requestProducts(){
        let request = SKProductsRequest(productIdentifiers: NSSet(objects: "1") as! Set<String>)
        request.delegate = self
        request.start()
    }
    
    func loadOffLineData(){
        if let data = readOfflineDateFromDisk("data.dat") {
            offlineData = data
        }
    }
    
    func setupUserLanguageLocale(){
        let userLanguage = Locale.preferredLanguages.description
        print("userlanguage: \(userLanguage)")
        self.languageLocale = Locale(identifier: Locale.identifier(fromComponents: NSDictionary(object: userLanguage, forKey: NSLocale.Key.languageCode as NSCopying) as! [String : String]))
    }
    
    func addObserver(_ observer:UserModelObserver){
        observers.append(observer)
    }
    
    func updateHomeLocale(_ locale:Locale){
        homeLocale = locale
        UserDefaults.standard.setValue(homeLocale.identifier, forKey: "homeLocale")
        UserDefaults.standard.synchronize()
        homeLocaleHasChanged()
    }
    
    func updateCurrentLocale(_ locale:Locale){
        currentLocale = locale
        UserDefaults.standard.setValue(currentLocale.identifier, forKey: "currentLocale")
        UserDefaults.standard.synchronize()
        currentLocaleHasChanged()
    }
    
    func updateOfflineData(_ data:[String:OfflineEntry]) {
        offlineData = data
    }
    
    func offlineDataHasChanged(){
        for observer in observers {
            observer.offlineDataHasChanged()
        }
    }
    
    func getActiveCurrentLocale() -> Locale{
        if let locale = overrideGPSLocale {
            return locale
        } else {
            return currentLocale
        }
    }
    
    func getActiveHomeLocale() -> Locale{
        if let locale = overrideLogicalLocale {
            return locale
        } else {
            return homeLocale
        }
    }
    
    func getConversionrate(_ fromLocale:Locale, toLocale:Locale) -> Double?{
        if let data = offlineData {
            let fromCountryCode = LocaleUtils.createCurrencyCodeFromLocale(fromLocale) as! String
            let toCountryCode = LocaleUtils.createCurrencyCodeFromLocale(toLocale) as! String
            let fromVal = data[fromCountryCode]?.value
            let toVal = data[toCountryCode]?.value
                
            if let from = fromVal, let to = toVal {
                    return to/from
            }
        }
        return nil
    }
    
    fileprivate func calculateHomeAmount(){
        if let conv = getConversionrate(getActiveCurrentLocale(), toLocale: getActiveHomeLocale()) {
            homeAmount = currentAmount! * conv
        }
    }
    
    fileprivate func calculateCurrentAmount(){
        if let conv = getConversionrate(getActiveHomeLocale(), toLocale: getActiveCurrentLocale()) {
            currentAmount = homeAmount! * conv
        }
    }
    
    func updateCurrentAmount(_ val:Double?){
        if let amount = val {
            currentAmount = amount
            calculateHomeAmount()
        } else {
            homeAmount = nil
        }
        for observer in self.observers {
            observer.homeAmountChanged()
        }
        
    }
    
    func updateHomeAmount(_ val:Double?){
        if let amount = val {
            homeAmount = amount
            calculateCurrentAmount()
        } else {
            currentAmount = nil
        }
        
        for observer in self.observers {
            observer.currentAmountChanged()
        }
    }
    
    func homeLocaleHasChanged(){
        for observer in self.observers {
            observer.homeLocaleHasChanged()
        }
        
    }
    
    func currentLocaleHasChanged(){
        for observer in self.observers {
            observer.currentLocaleHasChanged()
        }
    }
    
    func isManualSetupActive() -> Bool{
        return overrideGPSLocale != nil || overrideLogicalLocale != nil
    }
    
    func loadStateFromUserDefaults(){
        print("Loading state from userDefaults")
        let userDefaults = UserDefaults.standard

        if let current: AnyObject = userDefaults.value(forKey: "currentLocale") as AnyObject? {
            currentLocale = Locale(identifier: current as! String)
        }
        
        if let home: AnyObject = userDefaults.value(forKey: "homeLocale") as AnyObject? {
            homeLocale = Locale(identifier: home as! String)
        }
        
        if let overrideCurrent: AnyObject = userDefaults.value(forKey: "overrideGPSLocale") as AnyObject? {
            overrideGPSLocale = Locale(identifier: overrideCurrent as! String)
        }
        
        if let overrideHome: AnyObject = userDefaults.value(forKey: "overrideLogicalLocale") as AnyObject? {
            overrideLogicalLocale = Locale(identifier: overrideHome as! String)
        }
    }
    
    func printUserModel(){
        print("Current locale: \(LocaleUtils.createCountryNameFromLocale(currentLocale))")
        print("currentAmount: \(currentAmount)")
        print("Home locale: \(LocaleUtils.createCountryNameFromLocale(homeLocale))")
        print("homeAmount: \(homeAmount)")
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            removeAdProduct = (response.products[0] )
        }
    }

}
