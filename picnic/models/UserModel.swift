
import Foundation

 class UserModel : NSObject {
    
    var observers:[UserModelObserver]
    var homeLocale:NSLocale?
    var currentLocale:NSLocale?
    var convertionRate:Double?
    var homeAmount:Double?
    var currentAmount:Double?
    
    var overrideGPSLocale:NSLocale?
    var shouldOverrideGPS = false
    
    var overrideLogicalLocale:NSLocale?
    var shouldOverrideLogical = false
    
    override init(){
        self.observers = []
        super.init()
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
    
    func updateConvertionRate(convertionRate:Double){
        self.convertionRate = convertionRate
        convertionRateHasChanged()
    }
    
    func updateHomeAmount(amount:Double?) {
        self.homeAmount = amount;
        if let number = homeAmount {
            self.currentAmount = number*self.convertionRate!
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
        if let number = currentAmount {
            homeAmount = number*(1/self.convertionRate!)
        } else {
            homeAmount = nil
        }
        for observer in self.observers {
            observer.currentAmountChanged();
            observer.homeAmountChanged();
        }
    }
    
    func convertionRateHasChanged(){
        for observer in self.observers {
            observer.convertionRateHasChanged()
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
