
import Foundation
import BrightFutures
import UIKit

class ConverterViewController: UIViewController, UserModelObserver, UITextFieldDelegate {

    // -- UI Elements -- //
    var topCountryLabel:UILabel!
    var bottomCountryLabel:UILabel!
    var topTextField:UITextField!
    var bottomTextField:UITextField!
    var swapButton:UIButton!
    
    var refreshButton:UIButton!
    var settingsButton:UIButton!
    var refreshButtonItem:UIBarButtonItem!
    var settingsButtonItem:UIBarButtonItem!
    
    var shouldRefreshContiniueSpinning:Bool = false

    var topLabel:UILabel!
    var bottomLabel:UILabel!

    // -- App Elements -- //
    var userModel:UserModel!
    var locationManager:LocationManager!
    var conversionRateManager:ConversionRateManager!

    let userDefaults = NSUserDefaults.standardUserDefaults();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userModel = UserModel()
        
        userModel.addObserver(self)
        view.backgroundColor = UIColor.whiteColor()
        
        setupNavigationBar()
        
        locationManager = LocationManager(userModel: userModel)
        conversionRateManager = ConversionRateManager()
        
        topCountryLabel = UILabel()
        topCountryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        topTextField = createTextField()
        topTextField.addTarget(self, action: Selector("topAmountEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        bottomCountryLabel = UILabel()
        bottomCountryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

        bottomTextField = createTextField()
        bottomTextField.addTarget(self, action: Selector("bottomAmountEdited:"), forControlEvents: UIControlEvents.EditingChanged)

        topLabel = FAComponents.createFALabel("\u{f124}")
        bottomLabel = FAComponents.createFALabel("\u{f015}")
        
        swapButton = createSwapButton()
        
        view.addSubview(topCountryLabel)
        view.addSubview(topTextField)
        view.addSubview(swapButton)
        view.addSubview(bottomCountryLabel)
        view.addSubview(bottomTextField)
        view.addSubview(topLabel)
        view.addSubview(bottomLabel)
        
        let views: [NSObject : AnyObject] = ["topCountryLabel":topCountryLabel, "bottomCountryLabel":bottomCountryLabel,
            "topTextField":topTextField, "bottomTextField":bottomTextField, "swapButton":swapButton, "topIcon":topLabel, "bottomIcon":bottomLabel]
        
        self.setConstraints(views)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var shouldRefreshContiniueSpinning:Bool = false
        clearTextFields()
        refreshData()
    }
    
    func setupNavigationBar(){
        navigationController?.navigationBar.barTintColor = UIColor(netHex: 0x19B5FE)
        
        var font = UIFont(name: "Verdana", size:22)!
        var attributes:[NSObject : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationItem.title = "Picnic Currency"
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        var verticalOffset = 1.5 as CGFloat;
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(verticalOffset, forBarMetrics: UIBarMetrics.Default)
        
        refreshButton = FAComponents.createfontAwesomeButton("\u{f021}")
        refreshButton.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.TouchUpInside)
        refreshButtonItem = UIBarButtonItem(customView: refreshButton)
        
        settingsButton = FAComponents.createfontAwesomeButton("\u{f013}")
        settingsButton.addTarget(self, action: "settings:", forControlEvents: UIControlEvents.TouchUpInside)
        settingsButtonItem = UIBarButtonItem(customView: settingsButton)
        
        navigationItem.leftBarButtonItem = refreshButtonItem
        navigationItem.rightBarButtonItem = settingsButtonItem
    }

    
    func setConstraints(views: [NSObject:AnyObject]){
        
        var swapMargin = getSwapButtonMarginBasedOnDevice()
        var keyboardHeight = getKeyboardHeightBasedOnDevice()
        
        var screenSize = Double(view.bounds.height)
        var textFieldHeight = Int(screenSize * 0.10)
        var topTextFieldMarginTop = Int(screenSize * 0.14)
        var swapButtonMarginTopAndBottom = Int(screenSize * swapMargin)
        var countryLabelDistanceFromTextField = Int(screenSize * 0.003)
        var distanceFromEdge = Int(screenSize * 0.01)
        
        var textFieldFontSize = CGFloat(screenSize * 0.033)
        var swapButtonFontSize = CGFloat(screenSize * 0.082)
        var iconFontSize = CGFloat(screenSize * 0.045)
        
        self.topTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        self.swapButton.titleLabel!.font = UIFont(name: "FontAwesome", size: swapButtonFontSize)
        self.bottomTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        self.topLabel.font = UIFont(name: "FontAwesome", size: iconFontSize)
        self.bottomLabel.font = UIFont(name: "FontAwesome", size: iconFontSize)
        
        var visualFormat = String(format: "V:[topTextField(%d)]-%d-[swapButton]-%d-[bottomTextField(%d)]-%d-|",
            textFieldHeight,
            swapButtonMarginTopAndBottom,
            swapButtonMarginTopAndBottom,
            textFieldHeight,
            keyboardHeight)
        
        let verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "V:[topCountryLabel]-%d-[topTextField]",
            countryLabelDistanceFromTextField)
        
        let topCountrylabelSpaceToTextField = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        view.addConstraint(NSLayoutConstraint(item: topLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: topTextField, attribute: .CenterY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bottomLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: bottomTextField, attribute: .CenterY, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: topCountryLabel, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: topTextField, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        visualFormat = String(format: "H:|-%d-[swapButton]-%d-|",
            distanceFromEdge,
            distanceFromEdge)
        
        let swapButtonWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        let swapButtonHorizontalAlign = NSLayoutConstraint(item: swapButton, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
    
        view.addConstraint(NSLayoutConstraint(item: bottomCountryLabel, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: bottomTextField, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        visualFormat = String(format: "V:[bottomCountryLabel]-%d-[bottomTextField]",
            countryLabelDistanceFromTextField)
        
        let bottomCountrylabelbottomConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        let size: CGSize = bottomLabel.text!.sizeWithAttributes([NSFontAttributeName: bottomLabel.font])
        var labelWidth = size.width + CGFloat(2*distanceFromEdge)
        
        visualFormat = String(format: "H:|-%d-[topIcon(\(size.width))]-%d-[topTextField]-\(labelWidth)-|",
            distanceFromEdge,distanceFromEdge)
        
        let topTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "H:|-%d-[bottomIcon(\(size.width))]-%d-[bottomTextField]-\(labelWidth)-|",
            distanceFromEdge,distanceFromEdge)
        
        let bottomTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        self.view.addConstraints(verticalLayout)
        self.view.addConstraints(topCountrylabelSpaceToTextField)
        self.view.addConstraints(topTextFieldWidthConst)
        self.view.addConstraint(swapButtonHorizontalAlign)
        self.view.addConstraints(bottomCountrylabelbottomConst)
        self.view.addConstraints(bottomTextFieldWidthConst)
    }
    
    
    func getKeyboardHeightBasedOnDevice() -> Int{
        var keyboardHeight = 216
        
        if view.bounds.height > 667 {
            //iPhone 6 PLUS RAAAAAGE
            keyboardHeight = 226
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            keyboardHeight = 350
        }
        
        return keyboardHeight
        
    }
    
    func getSwapButtonMarginBasedOnDevice() -> Double{
        
        //Special case for iPhone 4
        if view.bounds.height < 500 {
            return 0.022
        }
        return 0.045
    }

    func refreshData(){
        shouldRefreshContiniueSpinning = true
        refreshButton.rotate360Degrees(duration: 2, completionDelegate: self)
        updateUserHomeLocale()
        
        locationManager.getUserCurrentLocale(true)
            .onSuccess { locale in
                self.updateUserCurrentLocale(locale)
                self.fetchCurrency()
            }
            .onFailure { error in
                self.displayFailedToCurrentLocation()
                self.updateUserCurrentLocale(NSLocale(localeIdentifier: "en_US"))
                self.fetchCurrency()
        }
    }
    
    func fetchCurrency() {
        conversionRateManager.getConvertionRate(self.userModel)
                .onSuccess { conv in
                    self.shouldRefreshContiniueSpinning = false
                    self.userModel.updateConvertionRate(conv) }
                .onFailure { error in
                    println("failed to get conv rate")
                    self.shouldRefreshContiniueSpinning = false
                    self.displayFailedToResolveCurrencyError()
                    self.userModel.updateConvertionRate(1.0)}
    }
    
    func swapButtonPressed(sender:UIButton!){
        self.view.endEditing(true)
        userModel.updateCurrentAmount(nil)
        userModel.updateHomeAmount(nil)
    }
    
    func updateUserCurrentLocale(locale:NSLocale){
        self.userModel.updateCurrentLocale(locale)
    }
    
    func updateUserHomeLocale() {
        let locale:NSLocale = locationManager.getUserHomeLocale(true)
        self.userModel.updateHomeLocale(locale)
    }
    
    func setBottomCountryText(){
        if let locale = self.userModel.homeLocale {
            let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as! String
            var country: String = userModel.languageLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
            bottomCountryLabel.text = country
        }
    }
    
    func setTopCountryText() {
        if let locale = userModel.currentLocale {
            let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as! String
            var country: String = userModel.languageLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
            topCountryLabel.text = country
        }
    }
    
    func setBottomCurrencyLabel() {
        if let locale = userModel.homeLocale {
            bottomTextField.placeholder = locale.objectForKey(NSLocaleCurrencyCode) as? String
        }

    }

    func setTopCurrencyLabel() {
        if let loc = userModel.currentLocale {
            topTextField.placeholder = loc.objectForKey(NSLocaleCurrencyCode) as? String
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func normalizeText(input:String) -> NSString{
        return input.stringByReplacingOccurrencesOfString(",", withString: ".", options: NSStringCompareOptions.LiteralSearch, range: nil) as NSString
    }
    
    func displayFailedToResolveCurrencyError(){
        var alert2 = UIAlertController(title: "Error", message: "Unable to access obtain the convertionrate. Please check your internet connection and try again later.", preferredStyle: UIAlertControllerStyle.Alert)
        alert2.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert2, animated: true, completion: nil)
    }
    
    func displayFailedToCurrentLocation(){
        var alert = UIAlertController(title: "Error", message: "Unable to detect your location. Please make sure Picnic is allowed the use of GPS under general settings.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func redraw(){
        setTopCountryText()
        setTopCurrencyLabel()
        setBottomCountryText()
        setBottomCurrencyLabel()
    }
    
    func homeLocaleHasChanged() {
        redraw()
    }

    func currentLocaleHasChanged() {
        redraw()
    }
    
    func topAmountEdited(theTextField:UITextField) -> Void {
        let normalizedNumber:NSString = self.normalizeText(topTextField.text)
        if normalizedNumber == "" {
            userModel.updateCurrentAmount(nil)
        } else {
            userModel.updateCurrentAmount(normalizedNumber.doubleValue)
        }
   
    }
    
    func bottomAmountEdited(theTextField:UITextField) -> Void {
        let normalizedNumber:NSString = self.normalizeText(bottomTextField.text)
            if normalizedNumber == "" {
                userModel.updateHomeAmount(nil)
            } else {
                userModel.updateHomeAmount(normalizedNumber.doubleValue)
            }
    }
    
    func clearTextFields() {
        self.topTextField.text = ""
        self.bottomTextField.text = ""
    }
    
    func createTextField() -> UITextField{
        var textField = UITextField()
        
        textField.delegate = self
        textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = "USD"
        textField.textAlignment = NSTextAlignment.Center
        textField.keyboardType = UIKeyboardType.DecimalPad
        textField.returnKeyType = UIReturnKeyType.Done

        return textField
    }
    
    func createSwapButton() -> UIButton{
        var swapButton = UIButton()
        swapButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        swapButton.setTitle("\u{f0ec}", forState: .Normal)
        swapButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        swapButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        swapButton.transform = CGAffineTransformMakeRotation(3.14/2)
        swapButton.addTarget(self, action: "swapButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return swapButton
    }
    
    func homeAmountChanged() {
        var text = ""
        if let amount = userModel.homeAmount {
            text = String(format: "%.2f", amount)
        }
        if(!bottomTextField.isFirstResponder()){
            bottomTextField.text = text
        }
    }
    
    func refresh(sender:UIButton!) {
        shouldRefreshContiniueSpinning = true
        refreshButton.rotate360Degrees(duration: 2, completionDelegate: self)
        refreshData()
        
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if self.shouldRefreshContiniueSpinning {
            refreshButton.rotate360Degrees(duration: 2, completionDelegate: self)
        }
    }
    
    func settings(sender:UIButton!) {
        let vc = MenuViewController(userModel: userModel)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func currentAmountChanged() {
        var text = ""
        if let amount = userModel.currentAmount {
            text = String(format: "%.2f", amount)
        }
        if(!topTextField.isFirstResponder()){
            topTextField.text = text
        }
    }
    
    func convertionRateHasChanged() {
    }
}

