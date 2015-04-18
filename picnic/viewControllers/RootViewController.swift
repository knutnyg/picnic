
import Foundation
import UIKit

class RootViewController: UIViewController {
    
//    var topBannerView:TopBannerViewController!
    var converterView:ConverterViewController!
    var userModel:UserModel!
    
    var refreshButton:UIButton!
    var settingsButton:UIButton!
    var refreshButtonItem:UIBarButtonItem!
    var settingsButtonItem:UIBarButtonItem!
    
    override func viewDidLoad() {
        
        userModel = UserModel()
        userModel.tm = TransitionManager()
        
        view.backgroundColor = UIColor.whiteColor()
        
        setupNavigationBar()
        
        converterView = ConverterViewController(userModel: userModel)
        converterView.view.setTranslatesAutoresizingMaskIntoConstraints(false)

        self.addChildViewController(converterView)
        view.addSubview(converterView.view)
        
        let views:[NSObject : AnyObject] = ["converter":converterView.view, "superView":self.view]
        
        setConstraintsiPhone(views)
    }
    func setConstraintsiPhone(views: [NSObject:AnyObject]){
        var bannerHeight = Int(self.view.bounds.height*0.1)
        var keyboardHeight = 216
        var converterHeight = Int(view.bounds.height) - bannerHeight - keyboardHeight
        
        var visualFormat = String(format: "V:|-66-[converter]-%d-|",
            keyboardHeight)
        
        var verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = "H:|-0-[converter]-0-|"
        
        var converterWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        view.addConstraints(verticalLayout)
        //        view.addConstraints(topBannerWidthConstraints)
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
//        navigationItem.leftBarButtonItem = refreshButton

    }
    
    func refresh(sender:UIButton!) {
        NSNotificationCenter.defaultCenter().postNotificationName("refreshPressed", object: nil)
        makeRefreshIconSpin()
    }
    
    func makeRefreshIconSpin(){
        refreshButton.rotate360Degrees(duration: 2, completionDelegate: self)
    }
    
    func settings(sender:UIButton!) {
        let vc = MenuViewController(userModel: userModel)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func createfontAwesomeButton(unicode:String) -> UIButton{
        var font = UIFont(name: "FontAwesome", size: 22)!
        let size: CGSize = unicode.sizeWithAttributes([NSFontAttributeName: font])
        
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        button.setTitle(unicode, forState: .Normal)
        button.titleLabel!.font = font
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.setTitleColor(UIColor(netHex: 0x19B5FE), forState: .Highlighted)
        
        return button
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



