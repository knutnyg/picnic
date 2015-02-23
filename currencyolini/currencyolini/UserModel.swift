
import Foundation

class UserModel : NSObject {
    
    var homeLocale:NSLocale
    var currentLocale:NSLocale
    
    override init(){
        self.homeLocale = NSLocale()
        self.currentLocale = NSLocale()
        super.init()
    }
}
