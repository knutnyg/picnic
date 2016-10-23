
import Foundation
import UIKit

class RootViewController: UIViewController {

    var converterView:ConverterViewController!
    var userModel:UserModel!
    
    var refreshButton:UIButton!
    var settingsButton:UIButton!
    var refreshButtonItem:UIBarButtonItem!
    var settingsButtonItem:UIBarButtonItem!
    
    var shouldRefreshContiniueSpinning:Bool = false
    
    func setConstraints(views: [NSObject:AnyObject]){
        
        var bannerHeight = Int(self.view.bounds.height*0.1)
        var keyboardHeight = 216
        var converterHeight = Int(view.bounds.height) - bannerHeight - keyboardHeight
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            keyboardHeight = 350
        }
        
        var visualFormat = String(format: "V:|-66-[converter]-%d-|",
            keyboardHeight)
        
        var verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = "H:|-0-[converter]-0-|"
        
        var converterWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        view.addConstraints(verticalLayout)
        view.addConstraints(converterWidthConstraints)
        
    }

    func setupNavigationBar(){
        navigationController?.navigationBar.barTintColor = UIColor(netHex: 0x19B5FE)
        
        var font = UIFont(name: "Verdana", size:22)!
        var attributes:[NSObject : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationItem.title = "Picnic Currency"
        navigationController?.navigationBar.titleTextAttributes = attributes

        var verticalOffset = 1.5 as CGFloat;
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(verticalOffset, forBarMetrics: UIBarMetrics.Default)
        
        settingsButton = createfontAwesomeButton("\u{f013}")
        settingsButton.addTarget(self, action: "settings:", forControlEvents: UIControlEvents.TouchUpInside)
        settingsButtonItem = UIBarButtonItem(customView: settingsButton)
        
        refreshButton = createfontAwesomeButton("\u{f021}")
        refreshButton.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.TouchUpInside)
        refreshButtonItem = UIBarButtonItem(customView: refreshButton)
        
        var spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        spacer.width = 0; // for example shift right bar button to the right
        
        navigationItem.leftBarButtonItems = [spacer, refreshButtonItem]

        navigationItem.rightBarButtonItem = settingsButtonItem

    }
    

    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if self.shouldRefreshContiniueSpinning {
            refreshButton.animateWithDuration(2.0, animations: {
                self.view.transform = CGAffineTransformMakeRotation((180.0 * CGFloat(M_PI)) / 180.0)
            })
        }
    }
    
    func settings(sender:UIButton!) {
        let vc = MenuViewController(userModel: userModel)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
        
    func createFABarButton(unicode:String, fontSize:CGFloat) -> UIBarButtonItem {
        var font = UIFont(name: "FontAwesome", size:fontSize)!
        var attributes:[NSObject : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        var item = UIBarButtonItem(title: unicode, style: UIBarButtonItemStyle.Done, target: self, action: "nil:")
        item.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        item.action = "test"
        
        return item
    }
    
    }



