
import Foundation
import UIKit

class ViewController: UIViewController {
    
    var topBannerView:TopBannerViewController!
    var converterView:ConverterViewController!
    var userModel:UserModel!
    
    override func viewDidLoad() {
        
        userModel = UserModel()
        
        topBannerView = TopBannerViewController(userModel: userModel)
            .withRefreshButton()
            .withSettingsButton()
        
        topBannerView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        converterView = ConverterViewController(userModel: userModel)
        converterView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addChildViewController(topBannerView)
        self.addChildViewController(converterView)
        view.addSubview(topBannerView.view)
        view.addSubview(converterView.view)
        
        let views:[NSObject : AnyObject] = ["topBanner":topBannerView.view, "converter":converterView.view, "superView":self.view]
        
        setupGUIBasedOnScreenSize(views)
    }
    
    func setupGUIBasedOnScreenSize(views: [NSObject:AnyObject]){
        let screenHeight = view.frame.height
        
        switch screenHeight {
        case 480: setupForiPhoneFour(views)
        case 568: setupForiPhoneFive(views)
        case 667: setupForiPhoneSix(views)
        case 736: setupForiPhoneSix(views)
        case 1024: setupForiPadTwo(views)
        default: println("default")
        }
    }
    
    func setupForiPhoneFour(views: [NSObject:AnyObject]){
        
        let constraintModel = ParentConstraintsModel(
            bannerHeight: 55,
            keyboardHeight: 216,
            screenHeight: Int(view.frame.height)
        )
        
        setConstraintsForiPhone(views, constraintModel: constraintModel)
    }
    
    func setupForiPhoneFive(views: [NSObject:AnyObject]){
        
        let constraintModel = ParentConstraintsModel(
            bannerHeight: 70,
            keyboardHeight: 216,
            screenHeight: Int(view.frame.height)
        )
        
        setConstraintsForiPhone(views, constraintModel: constraintModel)
    }
    
    func setupForiPhoneSix(views: [NSObject:AnyObject]){
        
        let constraintModel = ParentConstraintsModel(
            bannerHeight: 70,
            keyboardHeight: 216,
            screenHeight: Int(view.frame.height)
        )
        
        setConstraintsForiPhone(views, constraintModel: constraintModel)
    }
    
    func setupForiPadTwo(views: [NSObject:AnyObject]){
        let constraintModel = ParentConstraintsModel(
            bannerHeight: 70,
            keyboardHeight: 216,
            screenHeight: Int(view.frame.height)
        )
        
        setConstraintsForiPhone(views, constraintModel: constraintModel)
    }
    
    func setConstraintsForiPhone(views: [NSObject:AnyObject], constraintModel:ParentConstraintsModel){
        
        var visualFormat = String(format: "V:|-0-[topBanner(%d)]-0-[converter(%d)]-%d-|",
            constraintModel.bannerHeight,
            constraintModel.converterHeight,
            constraintModel.keyboardHeight)
        
        var verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = "H:|-0-[topBanner]-0-|"

        var topBannerWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = "H:|-0-[converter]-0-|"
        
        var converterWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        view.addConstraints(verticalLayout)
        view.addConstraints(topBannerWidthConstraints)
        view.addConstraints(converterWidthConstraints)
        
    }
}



