import Foundation
import UIKit


class TopBannerViewController : UIViewController {
    var contraintModel:TopBannerConstraintsModel!
    var settingsPanel:SettingsViewController?
    var userModel:UserModel!
    var refreshButton:UIButton!
    var settingsButton:UIButton!
    var backButton:UIButton!
    var activeViewController:UIViewController!
    var shouldRefreshIconSpin = false

    override func viewDidLoad() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDone:", name: "refreshDone", object: nil)
        
        self.view.backgroundColor = UIColor(netHex: 0x19B5FE)
        self.setConstraintModelBasedOnScreenSize()
    }
    
    func setConstraintModelBasedOnScreenSize(){
        
        let iPhoneSix = TopBannerConstraintsModel(
            refreshButtonLeftMargin: 15,
            settingsButtonRightMargin: 15,
            buttonsMarginTop: 19,
            nameLabelMarginTop: 19)
        
        let iPhoneFour = TopBannerConstraintsModel(
            refreshButtonLeftMargin: 15,
            settingsButtonRightMargin: 15,
            buttonsMarginTop: 17,
            nameLabelMarginTop: 17)
        
        let screenHeight = view.frame.height
        
        switch screenHeight {
            case 480: self.contraintModel = iPhoneFour
            case 568: self.contraintModel = iPhoneSix
            case 667: self.contraintModel = iPhoneSix
            case 736: self.contraintModel = iPhoneSix
            case 1024: self.contraintModel = iPhoneSix
            default: println("default")
        }
    }
    
    func withNameLabel(text:String) -> TopBannerViewController {
        
        var nameLabel:UILabel = createNameLabel(text)
        self.view.addSubview(nameLabel)

        var visualFormat = String(format: "V:|-%d-[name]",
            contraintModel.nameLabelMarginTop)
        
        let lableTop = NSLayoutConstraint.constraintsWithVisualFormat(visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: ["name":nameLabel])
        let lableCenter = NSLayoutConstraint(item: nameLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        
        self.view.addConstraint(lableCenter)
        self.view.addConstraints(lableTop)
        
        return self
    }
    
    func withRefreshButton() -> TopBannerViewController{
        refreshButton = createfontAwesomeButton("\u{f021}")
        refreshButton.addTarget(self, action: "refreshPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(refreshButton)
        
        var visualFormat = String(format: "H:|-%d-[refresh]",
            contraintModel.refreshButtonLeftMargin)
        
        let refreshLeftMarginConstraint = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: ["refresh":refreshButton])
        
        visualFormat = String(format: "V:|-%d-[refresh]",
            contraintModel.buttonsMarginTop)
        
        let refreshButtonTopMargin = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: ["refresh":refreshButton])
        
        self.view.addConstraints(refreshLeftMarginConstraint)
        self.view.addConstraints(refreshButtonTopMargin)
        
        return self
    }
    
    func withBackButton() -> TopBannerViewController{
        backButton = createfontAwesomeButton("\u{f060}")
        backButton.addTarget(self, action: "backPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(backButton)
        
        var visualFormat = String(format: "H:|-%d-[back]",
            self.contraintModel.refreshButtonLeftMargin)
        
        let LeftMarginConstraint = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: ["back":backButton])
        
        visualFormat = String(format: "V:|-%d-[back]",
            self.contraintModel.buttonsMarginTop)
        
        let TopMargin = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: ["back":backButton])
        
        self.view.addConstraints(LeftMarginConstraint)
        self.view.addConstraints(TopMargin)
        
        return self
    }
    
    
    func withSettingsButton() -> TopBannerViewController{
        settingsButton = createfontAwesomeButton("\u{f013}")
        settingsButton.addTarget(self, action: "settingsPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(settingsButton)
        
        var visualFormat = String(format: "H:[settings]-%d-|",
            contraintModel.settingsButtonRightMargin)
        
        let settingsRightMarginConstraint = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: ["settings":settingsButton])
        
        visualFormat = String(format: "V:|-%d-[settings]",
            contraintModel.buttonsMarginTop)
        
        let settingsButtonTopMargin = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: ["settings":settingsButton])
        
        self.view.addConstraints(settingsRightMarginConstraint)
        self.view.addConstraints(settingsButtonTopMargin)
        
        return self
    }
    
    
    func createNameLabel(text:String) -> UILabel{
        var nameLabel = UILabel()
        nameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        nameLabel.text = text
        nameLabel.font = UIFont(name: "verdana", size: 25)
        nameLabel.textColor = UIColor.whiteColor()

        return nameLabel
    }
    
    
    func createfontAwesomeButton(unicode:String) -> UIButton{
        var button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setTitle(unicode, forState: .Normal)
        button.titleLabel!.font = UIFont(name: "FontAwesome", size: 22)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.setTitleColor(UIColor(netHex: 0x19B5FE), forState: .Highlighted)
        return button
    }
    
    func settingsPressed(sender:UIButton!) {
        let vc = MenuViewController(userModel: userModel)
        vc.delegate = self
        vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

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
