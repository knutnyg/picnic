import Foundation
import UIKit


class TopBannerViewController : UIViewController {
    var userModel:UserModel!
    var refreshButton:UIButton!
    var settingsButton:UIButton!
    var backButton:UIButton!
    var activeViewController:UIViewController!
    var shouldRefreshIconSpin = false
    var bannerHeight:Int!
    var fontSize:CGFloat!

    override func viewDidLoad() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDone:", name: "refreshDone", object: nil)
        self.view.backgroundColor = UIColor(netHex: 0x19B5FE)
    }
    
    func withNameLabel(text:String) -> TopBannerViewController {
        
        var nameLabel:UILabel = createNameLabel(text)
        self.view.addSubview(nameLabel)

        view.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 3))
        view.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        
        return self
    }
    
    func withRefreshButton() -> TopBannerViewController{
        refreshButton = createfontAwesomeButton("\u{f021}")
        refreshButton.addTarget(self, action: "refreshPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(refreshButton)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-0-[refresh(50)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["refresh":refreshButton]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[refresh(50)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["refresh":refreshButton]))
        
        view.addConstraint(NSLayoutConstraint(item: refreshButton, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 3))
        
        return self
    }
    
    func withBackButton() -> TopBannerViewController{
        backButton = createfontAwesomeButton("\u{f060}")
        backButton.addTarget(self, action: "backPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(backButton)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-0-[back(50)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["back":backButton]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[back(50)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["back":backButton]))

        view.addConstraint(NSLayoutConstraint(item: backButton, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 3))
        
        return self
    }
    
    
    func withSettingsButton() -> TopBannerViewController{
        settingsButton = createfontAwesomeButton("\u{f013}")
        settingsButton.addTarget(self, action: "settingsPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(settingsButton)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[settings(50)]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["settings":settingsButton]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[settings(50)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["settings":settingsButton]))
        
        view.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 3))
        
        return self
    }
    
    
    func createNameLabel(text:String) -> UILabel{
        var nameLabel = UILabel()
        nameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        nameLabel.text = text
        nameLabel.font = UIFont(name: "verdana", size: fontSize)
        nameLabel.textColor = UIColor.whiteColor()

        return nameLabel
    }
    
    
    func createfontAwesomeButton(unicode:String) -> UIButton{
        var button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setTitle(unicode, forState: .Normal)
        button.titleLabel!.font = UIFont(name: "FontAwesome", size: fontSize)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.setTitleColor(UIColor(netHex: 0x19B5FE), forState: .Highlighted)
        return button
    }
    
    func settingsPressed(sender:UIButton!) {
        let vc = MenuViewController(userModel: userModel)
        vc.delegate = self
        vc.transitioningDelegate = userModel.tm
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func refreshPressed(sender:UIButton!) {
        NSNotificationCenter.defaultCenter().postNotificationName("refreshPressed", object: nil)
        makeRefreshIconSpin()
    }
    
    func backPressed(sender:UIButton!) {
        NSNotificationCenter.defaultCenter().postNotificationName("backPressed", object: activeViewController)
    }
    
    func makeRefreshIconSpin(){
        shouldRefreshIconSpin = true
        refreshButton.rotate360Degrees(duration: 2, completionDelegate: self)
        
    }
    
    func refreshDone(notification: NSNotification){
        shouldRefreshIconSpin = false
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if shouldRefreshIconSpin {
            refreshButton.rotate360Degrees(duration: 2, completionDelegate: self)
        }
    }
    
    init(userModel:UserModel, activeViewController:UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.userModel = userModel
        self.activeViewController = activeViewController
        self.bannerHeight = Int(view.bounds.height * 0.1)
        self.fontSize = CGFloat(Double(bannerHeight) / 2.6)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
