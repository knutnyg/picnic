
import Foundation
import StoreKit

 class UserModel : NSObject, SKProductsRequestDelegate {
    
    var observers:[UserModelObserver]
    var languageLocale:NSLocale!
    var homeLocale:NSLocale!
    var currentLocale:NSLocale!
    var homeAmount:Double?
    var currentAmount:Double?
    var priceString:String?
    var removeAdProduct:SKProduct?
    
    var overrideGPSLocale:NSLocale? {
        didSet {
            NSUserDefaults.standardUserDefaults().setValue(overrideGPSLocale?.localeIdentifier, forKey: "overrideGPSLocale")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var overrideLogicalLocale:NSLocale? {
        didSet {
            NSUserDefaults.standardUserDefaults().setValue(overrideLogicalLocale?.localeIdentifier, forKey: "overrideLogicalLocale")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var skipAds:Bool {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(skipAds, forKey: "skipAds")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    var offlineMode:Bool = false
    var offlineData:Dictionary<String,OfflineEntry>?
    
    var updatingHomeLocaleCounter:Int = 0
    var updatingCurrentLocaleCounter:Int = 0
    var updateingAllCurrenciesCounter:Int = 0
    
    override init(){
        self.observers = []
        self.homeLocale = NSLocale(localeIdentifier: "en_US")
        self.currentLocale = NSLocale(localeIdentifier: "en_US")

//        self.skipAds = NSUserDefaults.standardUserDefaults().boolForKey("skipAds")
        self.skipAds = true
        
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
        let userLanguage = NSLocale.preferredLanguages().description
        print("userlanguage: \(userLanguage)")
        self.languageLocale = NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents(NSDictionary(object: userLanguage, forKey: NSLocaleLanguageCode) as! [String : String]))
    }
    
    func addObserver(observer:UserModelObserver){
        observers.append(observer)
    }
    
    func updateHomeLocale(locale:NSLocale){
        homeLocale = locale
        NSUserDefaults.standardUserDefaults().setValue(homeLocale.localeIdentifier, forKey: "homeLocale")
        NSUserDefaults.standardUserDefaults().synchronize()
        homeLocaleHasChanged()
    }
    
    func updateCurrentLocale(locale:NSLocale){
        currentLocale = locale
        NSUserDefaults.standardUserDefaults().setValue(currentLocale.localeIdentifier, forKey: "currentLocale")
        NSUserDefaults.standardUserDefaults().synchronize()
        currentLocaleHasChanged()
    }
    
    func updateOfflineData(data:[String:OfflineEntry]) {
        offlineData = data
    }
    
    func offlineDataHasChanged(){
        for observer in observers {
            observer.offlineDataHasChanged()
        }
    }
    
    func getActiveCurrentLocale() -> NSLocale{
        if let locale = overrideGPSLocale {
            return locale
        } else {
            return currentLocale
        }
    }
    
    func getActiveHomeLocale() -> NSLocale{
        if let locale = overrideLogicalLocale {
            return locale
        } else {
            return homeLocale
        }
    }
    
    func getConversionrate(fromLocale:NSLocale, toLocale:NSLocale) -> Double?{
        if let data = offlineData {
            let fromCountryCode = LocaleUtils.createCurrencyCodeFromLocale(fromLocale) as! String
            let toCountryCode = LocaleUtils.createCurrencyCodeFromLocale(toLocale) as! String
            let fromVal = data[fromCountryCode]?.value
            let toVal = data[toCountryCode]?.value
                
            if let from = fromVal, to = toVal {
                    return to/from
            }
        }
        return nil
    }
    
    private func calculateHomeAmount(){
        if let conv = getConversionrate(getActiveCurrentLocale(), toLocale: getActiveHomeLocale()) {
            homeAmount = currentAmount! * conv
        }
    }
    
    private func calculateCurrentAmount(){
        if let conv = getConversionrate(getActiveHomeLocale(), toLocale: getActiveCurrentLocale()) {
            currentAmount = homeAmount! * conv
        }
    }
    
    func updateCurrentAmount(val:Double?){
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
    
    func updateHomeAmount(val:Double?){
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
        let userDefaults = NSUserDefaults.standardUserDefaults()

        if let current: AnyObject = userDefaults.valueForKey("currentLocale") {
            currentLocale = NSLocale(localeIdentifier: current as! String)
        }
        
        if let home: AnyObject = userDefaults.valueForKey("homeLocale") {
            homeLocale = NSLocale(localeIdentifier: home as! String)
        }
        
        if let overrideCurrent: AnyObject = userDefaults.valueForKey("overrideGPSLocale") {
            overrideGPSLocale = NSLocale(localeIdentifier: overrideCurrent as! String)
        }
        
        if let overrideHome: AnyObject = userDefaults.valueForKey("overrideLogicalLocale") {
            overrideLogicalLocale = NSLocale(localeIdentifier: overrideHome as! String)
        }
    }
    
    func printUserModel(){
        print("Current locale: \(LocaleUtils.createCountryNameFromLocale(currentLocale))")
        print("currentAmount: \(currentAmount)")
        print("Home locale: \(LocaleUtils.createCountryNameFromLocale(homeLocale))")
        print("homeAmount: \(homeAmount)")
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        if response.products.count > 0 {
            removeAdProduct = (response.products[0] as! SKProduct)
        }
    }

}
