
import Foundation

class UserModel : NSObject {
    
    var observers:[UserModelObserver]
    
    var homeLocale:NSLocale?
    var currentLocale:NSLocale?
    var convertionRate:Double?
    
    override init(){
        self.observers = []
        super.init()
    }
    
    func addObserver(observer:ViewController){
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
