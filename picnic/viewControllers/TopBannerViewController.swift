import Foundation
import UIKit


class TopBannerViewController : UIViewController {
    var contraintModel:TopBannerConstraintsModel!

    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor(netHex: 0x19B5FE)
        self.setConstraintModelBasedOnScreenSize()
        
        withNameLabel()
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
    
    func withNameLabel() -> TopBannerViewController {
        
        var nameLabel:UILabel = createNameLabel()
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
        var refreshButton:UIButton = createfontAwesomeButton("\u{f021}")
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
        var backButton:UIButton = createfontAwesomeButton("\u{f060}")
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
        var settingButton:UIButton = createfontAwesomeButton("\u{f013}")
        settingButton.addTarget(self, action: "settingsPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(settingButton)
        
        var visualFormat = String(format: "H:[settings]-%d-|",
            contraintModel.settingsButtonRightMargin)
        
        let settingsRightMarginConstraint = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: ["settings":settingButton])
        
        visualFormat = String(format: "V:|-%d-[settings]",
            contraintModel.buttonsMarginTop)
        
        let settingsButtonTopMargin = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: ["settings":settingButton])
        
        self.view.addConstraints(settingsRightMarginConstraint)
        self.view.addConstraints(settingsButtonTopMargin)
        
        return self
    }
    
    
    func createNameLabel() -> UILabel{
        var nameLabel = UILabel()
        nameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        nameLabel.text = "Picnic Currency"
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
        let vc = SettingsViewController()
        vc.delegate = self
        vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func refreshPressed(sender:UIButton!) {
        NSNotificationCenter.defaultCenter().postNotificationName("refreshPressed", object: nil)
    }
    
    func backPressed(sender:UIButton!) {
        NSNotificationCenter.defaultCenter().postNotificationName("backPressed", object: nil)
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
