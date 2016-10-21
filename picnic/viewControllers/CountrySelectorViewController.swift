
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
        view.backgroundColor = UIColor.white
        
        setupNavigationBar()
        
        topFilterField = createTextField()
        topFilterField.addTarget(self, action: #selector(CountrySelectorViewController.topFilterTextEdited(_:)), for: UIControlEvents.editingChanged)
        
        countryTableView = CountryTableViewController(userModel: userModel, selectorType: selectorType)
        countryTableView.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addChildViewController(countryTableView)
        
        view.addSubview(topFilterField)
        view.addSubview(countryTableView.view)
        
        let views:[String : AnyObject] = ["countryTable":countryTableView.view, "topFilter":topFilterField]
        
        let visualFormat = String(format: "V:|-74-[topFilter(40)]-[countryTable]-0-|")
        
        let verticalLayout = NSLayoutConstraint.constraints(
            withVisualFormat: visualFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[countryTable]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[topFilter]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(verticalLayout)  
    }
    
    
    func setupNavigationBar(){
        
        switch selectorType! {
        case .home_COUNTRY:
            navigationItem.title = "Home Country"
        case .gps:
            navigationItem.title = "Current Location"
    }
        
        let verticalOffset = 3 as CGFloat;
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(verticalOffset, for: UIBarMetrics.default)
        
        backButton = createfontAwesomeButton("\u{f060}")
        backButton.addTarget(self, action: #selector(CountrySelectorViewController.back(_:)), for: UIControlEvents.touchUpInside)
        backButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    func back(_: UIEvent) {
        navigationController?.popViewController(animated: true)
    }
    
    func createInstructionLabel() -> UILabel{
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 4
        
        switch selectorType! {
        case .home_COUNTRY:
            label.text = "Please set your preferred home country or use the one detected:"
            break
        case .gps:
            label.text = "Please set your preferred current country or use the one detected:"
        }
        return label

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func topFilterTextEdited(_ theTextField:UITextField) -> Void {
        if let text = theTextField.text {
            countryTableView.setCountryArray(countryTableView.createCountryNameList().filter{$0.countryName.lowercased().contains(text.lowercased())} )
        } else {
            countryTableView.setCountryArray(countryTableView.createCountryNameList())
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func backButtonPressed(_ notification: Notification) {
        navigationController?.popViewController(animated: true)
    }
    
    func createTextField() -> UITextField{
        let textField = UITextField()
        
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.placeholder = "Filter"
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.textAlignment = NSTextAlignment.center
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        
        return textField
    }
        
    /* ----   Initializers   ----  */
    
    init(userModel:UserModel, selectorType:CountrySelectorType) {
        super.init(nibName: nil, bundle: nil)
        self.userModel = userModel
        self.selectorType = selectorType
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
