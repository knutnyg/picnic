
import Foundation

protocol UserModelObserver {
    
    func homeLocaleHasChanged()
    func homeAmountChanged()
    func currentLocaleHasChanged()
    func currentAmountChanged()
    func convertionRateHasChanged()
}
