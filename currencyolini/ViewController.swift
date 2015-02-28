
import Foundation
import UIKit

class ViewController: UIViewController {
    
    var topBannerView:TopBannerViewController!
    var converterView:ConverterViewController!
    
    override func viewDidLoad() {
        
        let screenWidth = view.frame.width
        let screenHeight = view.frame.height
        
        topBannerView = TopBannerViewController()
        topBannerView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
//        converterView = ConverterViewController()
        
        self.addChildViewController(topBannerView)
//        self.addChildViewController(converterView)
        self.view.addSubview(topBannerView.view)
//        self.view.addSubview(converterView.view)
        
        let views:[NSObject : AnyObject] = ["topBanner":topBannerView.view, "superView":self.view]
        
//        var topBannerWidthConstraint = NSLayoutConstraint(item: topBannerView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100)
//        var topBannerHeightConstraint = NSLayoutConstraint(item: topBannerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 60)
        
        var topBannerWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat("[topBanner(\(screenWidth))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        var topBannerHeightConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[topBanner(70)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        self.view.addConstraints(topBannerWidthConstraints)
        self.view.addConstraints(topBannerHeightConstraints)
        
//        var converterWidthconstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[converterView(\(screenWidth))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
//        var converterHeightconstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[converterView(\(screenHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
//        var converterMarginBottom = NSLayoutConstraint.constraintsWithVisualFormat("V:[converterView]-216-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        
        
    }
    
    
}



