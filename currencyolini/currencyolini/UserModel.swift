
import Foundation

class UserModel : NSObject {
    
    var observers:[ViewController]
    
    var homeLocale:NSLocale
    var currentLocale:NSLocale
    
    override init(){
        self.homeLocale = NSLocale()
        self.currentLocale = NSLocale()
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
