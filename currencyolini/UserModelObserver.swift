
import Foundation

protocol UserModelObserver {
    
    func homeLocaleHasChanged()
    func currentLocaleHasChanged()
    func convertionRateHasChanged()
}
