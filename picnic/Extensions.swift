
import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension String {
    
    func contains(_ find: String) -> Bool{
        return self.range(of: find) != nil
    }
}

extension UIView {
    func rotate360Degrees(_ duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = duration
        
        if let delegate: CAAnimationDelegate = completionDelegate as! CAAnimationDelegate? {
            rotateAnimation.delegate = delegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

extension Date {
    
    func shortPrintable()-> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        
        return dateFormatter.string(from: self)
    }
    
    func mediumPrintable() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd. MMMM YYYY"
        
        return dateFormatter.string(from: self)
    }
    
    func relativePrintalbe() -> String {
        let elapsedTime = self.timeIntervalSinceNow * -1
        
        if elapsedTime < 3600 {
            return "\(Int(elapsedTime / 60))m"
        } else if elapsedTime < 86400.0 {
            return "\(Int(elapsedTime / 3600))h"
        } else {
            return "\(Int(elapsedTime / 86400))d"
        }
    }
    
    func utcFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        return dateFormatter.string(from: self)
    }
    
    func addDays(_ daysToAdd : Int) -> Date
    {
        let secondsInDays : TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(_ hoursToAdd : Int) -> Date
    {
        let secondsInHours : TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}

