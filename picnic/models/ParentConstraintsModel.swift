
import Foundation

class ParentConstraintsModel : NSObject{
    
    let bannerHeight:Int
    let keyboardHeight: Int
    let converterHeight: Int
    
    init(bannerHeight:Int, keyboardHeight:Int, screenHeight:Int){
        self.bannerHeight = bannerHeight
        self.keyboardHeight = keyboardHeight
        self.converterHeight = screenHeight - bannerHeight - keyboardHeight
    }
}
