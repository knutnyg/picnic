
import Foundation

 class UserModel : NSObject {
    
    var observers:[UserModelObserver]
    var languageLocale:NSLocale!
    var homeLocale:NSLocale?
    var currentLocale:NSLocale?
    var homeAmount:Double?
    var currentAmount:Double?
    
    var overrideGPSLocale:NSLocale?
    var shouldOverrideGPS = false
    
    var overrideLogicalLocale:NSLocale?
    var shouldOverrideLogical = false

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
    }
    
    func setupUserLanguageLocale(){
        var userLanguage = NSLocale.preferredLanguages().description
        languageLocale = NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents(NSDictionary(object: userLanguage, forKey: NSLocaleLanguageCode) as [NSObject : AnyObject]))
    }
    
    func addObserver(observer:UserModelObserver){
        observers.append(observer)
    }
    
    func updateHomeLocale(locale:NSLocale){
        self.homeLocale = locale
        homeLocaleHasChanged()
    }
    
    func updateCurrentLocale(locale:NSLocale){
        self.currentLocale = locale
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
            return curRate / homeRate
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
            
            for observer in self.observers {
                observer.homeAmountChanged()
            }
        } else {
            homeAmount = nil
        }
        
    }
    
    func updateHomeAmount(val:Double?){
        if let amount = val {
            homeAmount = amount
            calculateCurrentAmount()
            for observer in self.observers {
                observer.currentAmountChanged()
            }
        } else {
            currentAmount = nil
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
}
