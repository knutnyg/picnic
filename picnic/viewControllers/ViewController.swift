
import Foundation
import UIKit

class ViewController: UIViewController {
    
    var topBannerView:TopBannerViewController!
    var converterView:ConverterViewController!
    var userModel:UserModel!
    
    override func viewDidLoad() {
        
        userModel = UserModel()
        
        topBannerView = TopBannerViewController(userModel: userModel, activeViewController:self)
            .withRefreshButton()
            .withNameLabel("Picnic Currency")
            .withSettingsButton()
        
        topBannerView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        converterView = ConverterViewController(userModel: userModel)
        converterView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addChildViewController(topBannerView)
        self.addChildViewController(converterView)
        view.addSubview(topBannerView.view)
        view.addSubview(converterView.view)
        
        let views:[NSObject : AnyObject] = ["topBanner":topBannerView.view, "converter":converterView.view, "superView":self.view]
        
        setConstraints(views)
    }
    
    func setConstraints(views: [NSObject:AnyObject]){
        var bannerHeight = Int(self.view.bounds.height*0.1)
        var keyboardHeight = 216
        var converterHeight = Int(view.bounds.height) - bannerHeight - keyboardHeight
        
        var visualFormat = String(format: "V:|-0-[topBanner(%d)]-0-[converter(%d)]-%d-|",
            bannerHeight,
            converterHeight,
            keyboardHeight)
        
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



