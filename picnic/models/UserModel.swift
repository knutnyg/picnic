
import Foundation

 class UserModel : NSObject {
    
    var observers:[UserModelObserver]
    var homeLocale:NSLocale?
    var currentLocale:NSLocale?
    var convertionRate:Double?
    var homeAmount:Double = 0.0;
    var currentAmount:Double = 0.0;
    
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
    
    func setHomeLocale(locale:NSLocale){
        self.homeLocale = locale
        homeLocaleHasChanged()
    }
    
    func setCurrentLocale(locale:NSLocale){
        self.currentLocale = locale
        currentLocaleHasChanged()
    }
    
    func setConvertionRate(convertionRate:Double){
        self.convertionRate = convertionRate
        convertionRateHasChanged()
    }
    
    func setHomeAmount(amount:Double) {
        self.homeAmount = amount;
        self.currentAmount = amount*self.convertionRate!
        for observer in self.observers {
            observer.homeAmountChanged();
            observer.currentAmountChanged();
        }
    }
    
    func setCurrentAmount(amount:Double) {
        self.currentAmount = amount;
        self.homeAmount = amount*(1/self.convertionRate!)
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
}
