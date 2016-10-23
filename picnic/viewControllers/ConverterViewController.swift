
import Foundation
import UIKit
import iAd

class ConverterViewController: UIViewController, UserModelObserver, UITextFieldDelegate, ADBannerViewDelegate {

    // -- UI Elements -- //
    var topCountryLabel:UILabel!
    var bottomCountryLabel:UILabel!
    var topTextField:UITextField!
    var bottomTextField:UITextField!
    var swapButton:UIButton!
    var pointButton:UIButton!
    var houseButton:UIButton!
    
    var refreshButton:UIButton!
    var settingsButton:UIButton!
    var refreshButtonItem:UIBarButtonItem!
    var settingsButtonItem:UIBarButtonItem!

    var topLabel:UILabel!
    var bottomLabel:UILabel!
    var dataAgeLabel:UILabel!

    // -- App Elements -- //
    var userModel:UserModel!
    var gpsLocationManager:GPSLocationManager!
    var conversionRateManager:ConversionRateManager!

    let userDefaults = UserDefaults.standard;
    var storedFileName = "data.dat"
    
    var adBannerView:ADBannerView!
    var adBannerConstraint:[NSLayoutConstraint]!
    
    var interAd:ADInterstitialAd?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userModel = UserModel()
        userModel.loadOffLineData()
        userModel.loadStateFromUserDefaults()
        
        userModel.addObserver(self)
        view.backgroundColor = UIColor.white
        
        setupNavigationBar()
        
        gpsLocationManager = GPSLocationManager(userModel: userModel)
        conversionRateManager = ConversionRateManager(userModel: userModel)
        conversionRateManager.storedFileName = storedFileName
        
        topCountryLabel = UILabel()
        topCountryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topTextField = createTextField()
        topTextField.addTarget(self, action: #selector(ConverterViewController.topAmountEdited(_:)), for: UIControlEvents.editingChanged)
        
        bottomCountryLabel = UILabel()
        bottomCountryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bottomTextField = createTextField()
        bottomTextField.addTarget(self, action: #selector(ConverterViewController.bottomAmountEdited(_:)), for: UIControlEvents.editingChanged)
        
        pointButton = createFAButton("\u{f124}")
        pointButton.addTarget(self, action: #selector(ConverterViewController.pointPressed(_:)), for: UIControlEvents.touchUpInside)
        
        houseButton = createFAButton("\u{f015}")
        houseButton.addTarget(self, action: #selector(ConverterViewController.housePressed(_:)), for: UIControlEvents.touchUpInside)
        
        dataAgeLabel = createLabel("")
        
        swapButton = createFAButton("\u{f0ec}")
        swapButton.transform = CGAffineTransform(rotationAngle: 3.14/2)
        swapButton.addTarget(self, action: #selector(ConverterViewController.swapButtonPressed(_:)), for: UIControlEvents.touchUpInside)

        view.addSubview(topCountryLabel)
        view.addSubview(topTextField)
        view.addSubview(swapButton)
        view.addSubview(bottomCountryLabel)
        view.addSubview(bottomTextField)
        view.addSubview(pointButton)
        view.addSubview(houseButton)
        view.addSubview(dataAgeLabel)
        
        let views: [String : AnyObject] = ["topCountryLabel":topCountryLabel, "bottomCountryLabel":bottomCountryLabel,
            "topTextField":topTextField, "bottomTextField":bottomTextField, "swapButton":swapButton, "topIcon":pointButton, "bottomIcon":houseButton, "dataAgeLabel":dataAgeLabel]
        
        self.setConstraints(views)
    }

    func readOfflineDataFromDisk() {
        if let data = readOfflineDateFromDisk(storedFileName){
            userModel.offlineData = data
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        clearTextFields()
        redraw()
        refreshData()
        
        if(!userModel.skipAds) {
            addBanner()
        }
    }
    
    func addBanner(){
        adBannerView = ADBannerView()
        adBannerView.translatesAutoresizingMaskIntoConstraints = false
        adBannerView.delegate = self
        view.addSubview(adBannerView)
        let views:[String:AnyObject] = ["adBanner":adBannerView]
        adBannerConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[adBanner]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(adBannerConstraint)
    }
    
    func removeBanner(){
        adBannerView.removeFromSuperview()
        view.removeConstraints(adBannerConstraint)
        adBannerView.delegate = nil
        adBannerView = nil
    }
    
    func bannerView(_ banner: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
        print("Error: \(error)")
        banner.isHidden = true
    }
    
    func setupNavigationBar(){
        navigationController?.navigationBar.barTintColor = UIColor(netHex: 0x19B5FE)
        
        let font = UIFont(name: "Verdana", size:22)!
        let attributes:[String : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.white]
        navigationItem.title = "Picnic Currency"
        navigationController!.navigationBar.titleTextAttributes = attributes
        
        let verticalOffset = 1.5 as CGFloat;
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(verticalOffset, for: UIBarMetrics.default)
        
        refreshButton = createfontAwesomeButton("\u{f021}")
        refreshButton.addTarget(self, action: #selector(ConverterViewController.refresh(_:)), for: UIControlEvents.touchUpInside)
        refreshButtonItem = UIBarButtonItem(customView: refreshButton)
        
        settingsButton = createfontAwesomeButton("\u{f013}")
        settingsButton.addTarget(self, action: #selector(ConverterViewController.settings(_:)), for: UIControlEvents.touchUpInside)
        settingsButtonItem = UIBarButtonItem(customView: settingsButton)
        
        navigationItem.leftBarButtonItem = refreshButtonItem
        navigationItem.rightBarButtonItem = settingsButtonItem
    }

    
    func setConstraints(_ views: [String:AnyObject]){
        
        let swapMargin = getSwapButtonMarginBasedOnDevice()
        let keyboardHeight = getKeyboardHeightBasedOnDevice()
        
        let screenSize = Double(view.bounds.height)
        let textFieldHeight = Int(screenSize * 0.10)

        let swapButtonMarginTopAndBottom = Int(screenSize * swapMargin)
        let countryLabelDistanceletmTextField = Int(screenSize * 0.003)
        let distanceFromEdge = Int(screenSize * 0.01)
        
        let textFieldFontSize = CGFloat(screenSize * 0.033)
        let swapButtonFontSize = CGFloat(screenSize * 0.082)
        let iconFontSize = CGFloat(screenSize * 0.045)
        
        self.topTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        self.swapButton.titleLabel!.font = UIFont(name: "FontAwesome", size: swapButtonFontSize)
        self.bottomTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        self.pointButton.titleLabel!.font = UIFont(name: "FontAwesome", size: iconFontSize)
        self.houseButton.titleLabel!.font = UIFont(name: "FontAwesome", size: iconFontSize)
        
        var visualFormat = String(format: "V:[topTextField(%d)]-%d-[swapButton]-%d-[bottomTextField(%d)]-%d-|",
            textFieldHeight,
            swapButtonMarginTopAndBottom,
            swapButtonMarginTopAndBottom,
            textFieldHeight,
            keyboardHeight)
        
        
        let verticalLayout = NSLayoutConstraint.constraints(withVisualFormat: visualFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        visualFormat = String(format: "V:[topCountryLabel]-%d-[topTextField]",
            countryLabelDistanceletmTextField)
        
        let topCountrylabelSpaceToTextField = NSLayoutConstraint.constraints(
            withVisualFormat: visualFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        view.addConstraint(NSLayoutConstraint(item: pointButton, attribute: NSLayoutAttribute.centerY, relatedBy: .equal, toItem: topTextField, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: houseButton, attribute: NSLayoutAttribute.centerY, relatedBy: .equal, toItem: bottomTextField, attribute: .centerY, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: topCountryLabel, attribute: NSLayoutAttribute.left, relatedBy: .equal, toItem: topTextField, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0))
        
        visualFormat = String(format: "H:|-%d-[swapButton]-%d-|",
            distanceFromEdge,
            distanceFromEdge)
        
        let swapButtonHorizontalAlign = NSLayoutConstraint(item: swapButton, attribute: NSLayoutAttribute.centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
    
        view.addConstraint(NSLayoutConstraint(item: bottomCountryLabel, attribute: NSLayoutAttribute.left, relatedBy: .equal, toItem: bottomTextField, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0))
        
        visualFormat = String(format: "V:[bottomCountryLabel]-%d-[bottomTextField]",
            countryLabelDistanceletmTextField)
        
        let bottomCountrylabelbottomConst = NSLayoutConstraint.constraints(
            withVisualFormat: visualFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        let size: CGSize = houseButton.titleLabel!.text!.size(attributes: [NSFontAttributeName: houseButton.titleLabel!.font])
        let labelWidth = size.width + CGFloat(2*distanceFromEdge)
        
        visualFormat = String(format: "H:|-%d-[topIcon(\(size.width))]-%d-[topTextField]-\(labelWidth)-|",
            distanceFromEdge,distanceFromEdge)
        
        let topTextFieldWidthConst = NSLayoutConstraint.constraints(
            withVisualFormat: visualFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        visualFormat = String(format: "H:|-%d-[bottomIcon(\(size.width))]-%d-[bottomTextField]-\(labelWidth)-|",
            distanceFromEdge,distanceFromEdge)
        
        let bottomTextFieldWidthConst = NSLayoutConstraint.constraints(
            withVisualFormat: visualFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        view.addConstraint(NSLayoutConstraint(item: dataAgeLabel, attribute: NSLayoutAttribute.centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: dataAgeLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: bottomTextField, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: CGFloat(keyboardHeight / 2)))

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
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
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
        if !shouldRefreshContiniueSpinning() {
//           refreshButton.rotate360Degrees(2, completionDelegate: self)
        }
        
        if userModel.removeAdProduct == nil {
            userModel.requestProducts()
        }

        updateOfflineData()
        updateUserHomeLocale()
        updateUserCurrentLocale()
    }
    
    func updateOfflineData(){
        userModel.updateingAllCurrenciesCounter += 1
        conversionRateManager.updateAllCurrencies()
    }
    
    func updateUserHomeLocale() {
        userModel.updatingHomeLocaleCounter += 1
        gpsLocationManager.updateUserHomeLocale()
    }
    
    func updateUserCurrentLocale(){
        userModel.updatingCurrentLocaleCounter = 1
        gpsLocationManager.updateUserCurrentLocale()
    }
    
    func swapButtonPressed(_ sender:UIButton){
        self.view.endEditing(true)
        let tempLocale = userModel.homeLocale
        userModel.homeLocale = userModel.currentLocale
        userModel.currentLocale = tempLocale
        
        let tempOverrideLocal = userModel.overrideGPSLocale
        userModel.overrideGPSLocale = userModel.overrideLogicalLocale
        userModel.overrideLogicalLocale = tempOverrideLocal
        
        topTextField.text = ""
        bottomTextField.text = ""
        
        redraw()
    }
    
    func housePressed(_ sender:UIButton){
        let vc = CountrySelectorViewController(userModel: userModel, selectorType: CountrySelectorType.home_COUNTRY)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pointPressed(_ sender:UIButton){
        let vc = CountrySelectorViewController(userModel: userModel, selectorType: CountrySelectorType.gps)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateUserCurrentLocale(_ locale:Locale){
        self.userModel.updateCurrentLocale(locale)
    }
    
    func setBottomCountryText(){
        let countryCode:String = (userModel.getActiveHomeLocale() as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
        let country: String = (userModel.languageLocale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)!
        bottomCountryLabel.text = country
        
    }
    
    func setTopCountryText() {        
        let countryCode:String = (userModel.getActiveCurrentLocale() as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
        let country: String = (userModel.languageLocale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)!
        topCountryLabel.text = country
    }
    
    func setBottomCurrencyLabel() {
        bottomTextField.placeholder = (userModel.getActiveHomeLocale() as NSLocale).object(forKey: NSLocale.Key.currencyCode) as? String
    }

    func setTopCurrencyLabel() {
        topTextField.placeholder = (userModel.getActiveCurrentLocale() as NSLocale).object(forKey: NSLocale.Key.currencyCode) as? String
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func normalizeText(_ input:String) -> NSString{
        return input.replacingOccurrences(of: ",", with: ".", options: NSString.CompareOptions.literal, range: nil) as NSString
    }
    
    func displayFailedToResolveCurrencyError(){
        let alert2 = UIAlertController(title: "Error", message: "Unable to access obtain the convertionrate. Please check your internet connection and try again later.", preferredStyle: UIAlertControllerStyle.alert)
        alert2.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert2, animated: true, completion: nil)
    }
    
    func displayFailedToCurrentLocation(){
        let alert = UIAlertController(title: "Error", message: "Unable to detect your location. Please make sure Picnic is allowed the use of GPS under general settings.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func redraw(){
        setTopCountryText()
        setTopCurrencyLabel()
        topAmountEdited(topTextField)
        setBottomCountryText()
        setBottomCurrencyLabel()
        bottomAmountEdited(bottomTextField)
        checkDataAge()
    }
    
    func homeLocaleHasChanged() {
        redraw()
    }

    func currentLocaleHasChanged() {
        redraw()
    }
    
    func offlineDataHasChanged() {
        redraw()
    }
    
    func topAmountEdited(_ theTextField:UITextField) -> Void {
        let normalizedNumber:NSString = self.normalizeText(topTextField.text!)
        if normalizedNumber == "" {
            userModel.updateCurrentAmount(nil)
        } else {
            userModel.updateCurrentAmount(normalizedNumber.doubleValue)
        }
   
    }
    
    func bottomAmountEdited(_ theTextField:UITextField) -> Void {
        let normalizedNumber:NSString = self.normalizeText(bottomTextField.text!)
            if normalizedNumber == "" {
                userModel.updateHomeAmount(nil)
            } else {
                userModel.updateHomeAmount(normalizedNumber.doubleValue)
            }
    }
    
    func homeAmountChanged() {
        var text = ""
        if let amount = userModel.homeAmount {
            text = String(format: "%.2f", amount)
        }
        if(!bottomTextField.isFirstResponder){
            bottomTextField.text = text
        }
    }
    
    func currentAmountChanged() {
        var text = ""
        if let amount = userModel.currentAmount {
            text = String(format: "%.2f", amount)
        }
        if(!topTextField.isFirstResponder){
            topTextField.text = text
        }
    }
    
    func clearTextFields() {
        self.topTextField.text = ""
        self.bottomTextField.text = ""
    }
    
    func checkDataAge(){
        if let offlineData = userModel.offlineData {
            if let entry = offlineData["USD"] {
                    self.dataAgeLabel.text = "Last updated: \(entry.timeStamp.relativePrintalbe())"
            }
        }
    }
    
    func createTextField() -> UITextField{
        let textField = UITextField()
        
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.placeholder = "USD"
        textField.textAlignment = NSTextAlignment.center
        textField.keyboardType = UIKeyboardType.decimalPad
        textField.returnKeyType = UIReturnKeyType.done

        return textField
    }
    
    func createSwapButton() -> UIButton{
        let swapButton = UIButton()
        swapButton.translatesAutoresizingMaskIntoConstraints = false
        swapButton.setTitle("\u{f0ec}", for: UIControlState())
        swapButton.setTitleColor(UIColor.black, for: UIControlState())
        swapButton.setTitleColor(UIColor.white, for: .highlighted)
        swapButton.transform = CGAffineTransform(rotationAngle: 3.14/2)
        swapButton.addTarget(self, action: #selector(ConverterViewController.swapButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        return swapButton
    }
    
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let val = shouldRefreshContiniueSpinning()
        if val {
//            refreshButton.rotate360Degrees(2, completionDelegate: self)
        }
    }
    
    func refresh(_ sender:UIButton!) {
        refreshData()
    }
    
    func shouldRefreshContiniueSpinning() -> Bool{
//        print("\(userModel.updateingAllCurrenciesCounter) \(userModel.updatingHomeLocaleCounter) \(userModel.updatingCurrentLocaleCounter)")
        
        return userModel.updateingAllCurrenciesCounter > 0 ||
        userModel.updatingCurrentLocaleCounter > 0 ||
        userModel.updatingHomeLocaleCounter > 0
    }
    
    func settings(_ sender:UIButton!) {
        let vc = MenuViewController(userModel: userModel)
        vc.delegate = self

        if !userModel.skipAds {
            interstitialPresentationPolicy = ADInterstitialPresentationPolicy.manual
            requestInterstitialAdPresentation()
        }

        if adBannerView != nil {
            removeBanner()
        }
        navigationController?.pushViewController(vc, animated: true)

    }
}

