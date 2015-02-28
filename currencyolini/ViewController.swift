
import Foundation
import UIKit

class ViewController: UIViewController {
    
    var topBannerView:TopBannerViewController!
    var converterView:ConverterViewController!
    
    override func viewDidLoad() {
        
        let screenWidth = Int(view.frame.width)
        let screenHeight = Int(view.frame.height)
        let topPanelHeight = 55
        let keyboardHeight = 216
        let converterPanelHeight = (screenHeight - topPanelHeight - keyboardHeight)
        
        topBannerView = TopBannerViewController()
        topBannerView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        converterView = ConverterViewController()
        converterView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addChildViewController(topBannerView)
        self.addChildViewController(converterView)
        view.addSubview(topBannerView.view)
        view.addSubview(converterView.view)
        
        let views:[NSObject : AnyObject] = ["topBanner":topBannerView.view, "converter":converterView.view, "superView":self.view]

        var topBannerWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat("[topBanner(\(screenWidth))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        var topBannerHeightConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[topBanner(\(topPanelHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        view.addConstraints(topBannerWidthConstraints)
        view.addConstraints(topBannerHeightConstraints)
        
        var converterMarginTop = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[topBanner]-0-[converter]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        var converterWidthconstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[converter(\(screenWidth))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        var converterHeightconstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[converter(\(converterPanelHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        var converterMarginBottom = NSLayoutConstraint.constraintsWithVisualFormat("V:[converter]-216-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        view.addConstraints(converterMarginTop)
        view.addConstraints(converterWidthconstraints)
        view.addConstraints(converterHeightconstraints)
        view.addConstraints(converterMarginBottom)
    }
    
    
}



