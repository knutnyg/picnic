
import Foundation

 class UserModel : NSObject {
    
    var observers:[UserModelObserver]
    var languageLocale:NSLocale!
    var homeLocale:NSLocale!
    var currentLocale:NSLocale!
    var homeAmount:Double?
    var currentAmount:Double?
    
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
    
    var shouldOverrideGPS = false {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(shouldOverrideGPS, forKey: "shouldOverrideCurrentLocale")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var shouldOverrideLogical = false {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(shouldOverrideLogical, forKey: "shouldOverrideHomeLocale")
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

        super.init()
        self.setupUserLanguageLocale()
        
        if let data = readOfflineDateFromDisk("data.dat") {
            offlineData = data
        }
        
        loadStateFromUserDefaults()
    }
    
    func setupUserLanguageLocale(){
        var userLanguage = NSLocale.preferredLanguages().description
        languageLocale = NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents(NSDictionary(object: userLanguage, forKey: NSLocaleLanguageCode) as [NSObject : AnyObject]))
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
    
    private func calculateConversionRate() -> Double?{
        
        var activeHomeLocale:NSLocale?
        if shouldOverrideLogical {
            activeHomeLocale = overrideLogicalLocale
        } else {
            activeHomeLocale = homeLocale
        }
        
        var activeCurrentLocale:NSLocale?
        if shouldOverrideGPS {
            activeCurrentLocale = overrideGPSLocale
        } else {
            activeCurrentLocale = currentLocale
        }
        
        var homeRate:Double = 0
        var curRate:Double = 0
        if let locale:NSLocale = activeHomeLocale, cc:String = locale.objectForKey(NSLocaleCurrencyCode) as? String, od = offlineData {
            if let rate = od[cc]?.value{
                homeRate = rate
            }
        }
        
        if let locale:NSLocale = activeCurrentLocale, cc:String = locale.objectForKey(NSLocaleCurrencyCode) as? String, od = offlineData {
            if let rate = od[cc]?.value{
                curRate = rate
            }
        }
        
        if homeRate != 0 && curRate != 0 {
            return homeRate / curRate
        }
        
        return nil
    }
    
    private func calculateHomeAmount(){
        if let conv = calculateConversionRate() {
            homeAmount = currentAmount! * conv
        }
    }
    
    private func calculateCurrentAmount(){
        if let conv = calculateConversionRate() {
            currentAmount = homeAmount! * (1/conv)
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
        return shouldOverrideGPS || shouldOverrideLogical
    }
    
    func loadStateFromUserDefaults(){
        println("Loading state from userDefaults")
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
        
        shouldOverrideGPS = userDefaults.boolForKey("shouldOverrideCurrentLocale")
        shouldOverrideLogical = userDefaults.boolForKey("shouldOverrideHomeLocale")
    }
    
    func printUserModel(){
        println("Current locale: \(LocaleUtils.createCountryNameFromLocale(currentLocale))")
        println("shouldOverrideCurrentLocale: \(shouldOverrideGPS)")
        println("currentAmount: \(currentAmount)")
        println("Home locale: \(LocaleUtils.createCountryNameFromLocale(homeLocale))")
        println("shouldOverrideHomeLocale: \(shouldOverrideLogical)")
        println("homeAmount: \(homeAmount)")
    }
}
