
import Foundation

 class UserModel : NSObject {
    
    var observers:[UserModelObserver]
    var languageLocale:NSLocale!
    var homeLocale:NSLocale?
    var currentLocale:NSLocale?
    var convertionRate:Double?
    var conversionRateTimeStamp:NSDate?
    var homeAmount:Double?
    var currentAmount:Double?
    
    var overrideGPSLocale:NSLocale?
    var shouldOverrideGPS = false
    
    var overrideLogicalLocale:NSLocale?
    var shouldOverrideLogical = false
    
    var offlineMode:Bool = false
    var offlineData:Dictionary<String,OfflineEntry>?
    
    override init(){
        self.observers = []
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
    
    func updateHomeAmount(amount:Double?) {
        self.homeAmount = amount;
        if let number = homeAmount, convertionRate = self.convertionRate {
            self.currentAmount = number*convertionRate
        } else {
            self.currentAmount = nil
        }

        for observer in self.observers {
            observer.homeAmountChanged();
            observer.currentAmountChanged();
        }
    }
    
    func updateCurrentAmount(amount:Double?) {
        currentAmount = amount;
        if let number = currentAmount, convertionRate = self.convertionRate {
            homeAmount = number*(1/convertionRate)
        } else {
            homeAmount = nil
        }
        for observer in self.observers {
            observer.currentAmountChanged();
            observer.homeAmountChanged();
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
