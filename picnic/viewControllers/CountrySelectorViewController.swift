
import Foundation
import UIKit
import BButton

class CountrySelectorViewController : UIViewController, UITextFieldDelegate {
    
    var instructionLabel:UILabel!
    var useDetectedButton:BButton!
    
    var countryTableView:CountryTableViewController!
    var topFilterField:UITextField!
    var delegate:UIViewController!=nil
    var userModel:UserModel!
    var selectorType:CountrySelectorType!
    
    var backButton:UIButton!
    var backButtonItem:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        setupNavigationBar()
        
        topFilterField = createTextField()
        topFilterField.addTarget(self, action: Selector("topFilterTextEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        countryTableView = CountryTableViewController(userModel: userModel, selectorType: selectorType)
        countryTableView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addChildViewController(countryTableView)
        
        view.addSubview(topFilterField)
        view.addSubview(countryTableView.view)
        
        let views:[NSObject : AnyObject] = ["countryTable":countryTableView.view, "topFilter":topFilterField]
        
        var visualFormat = String(format: "V:|-74-[topFilter(40)]-[countryTable]-0-|")
        
        var verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[countryTable]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[topFilter]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(verticalLayout)  
    }
    
    
    func setupNavigationBar(){
        var font = UIFont(name: "Verdana", size:22)!
        var attributes:[NSObject : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        switch selectorType! {
        case .HOME_COUNTRY:
            navigationItem.title = "Home Country"
        case .GPS:
            navigationItem.title = "Current Location"
    }
        
        var verticalOffset = 3 as CGFloat;
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(verticalOffset, forBarMetrics: UIBarMetrics.Default)
        
        backButton = createfontAwesomeButton("\u{f060}")
        backButton.addTarget(self, action: "back:", forControlEvents: UIControlEvents.TouchUpInside)
        backButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    func back(UIEvent) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func createInstructionLabel() -> UILabel{
        var label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 4
        
        switch selectorType! {
        case .HOME_COUNTRY:
            label.text = "Please set your preferred home country or use the one detected:"
            break
        case .GPS:
            label.text = "Please set your preferred current country or use the one detected:"
        }
        return label

    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func topFilterTextEdited(theTextField:UITextField) -> Void {
        if(theTextField.text.isEmpty){
            countryTableView.setCountryArray(countryTableView.createCountryNameList())
        } else {
            countryTableView.setCountryArray(countryTableView.createCountryNameList().filter{$0.countryName.lowercaseString.contains(theTextField.text.lowercaseString)} )
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func backButtonPressed(notification: NSNotification) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func createTextField() -> UITextField{
        var textField = UITextField()
        
        textField.delegate = self
        textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = "Filter"
        textField.autocorrectionType = UITextAutocorrectionType.No
        textField.textAlignment = NSTextAlignment.Center
        textField.keyboardType = UIKeyboardType.Default
        textField.returnKeyType = UIReturnKeyType.Done
        
        return textField
    }
    
    func gpsButtonSetAutomaticallyPressed(sender:UIButton!){
        userModel.shouldOverrideGPS = false
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func logicalButtonSetAutomaticallyPressed(sender:UIButton!){
        userModel.shouldOverrideLogical = false
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    /* ----   Initializers   ----  */
    
    init(userModel:UserModel, selectorType:CountrySelectorType) {
        super.init(nibName: nil, bundle: nil)
        self.userModel = userModel
        self.selectorType = selectorType
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}