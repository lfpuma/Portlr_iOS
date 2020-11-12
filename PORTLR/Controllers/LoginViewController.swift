//
//  LoginViewController.swift
//  PORTLR
//
//  Created by Hunain on 21/05/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit
import KYDrawerController

class LoginViewController: UIViewController, UITextFieldDelegate {

    //MARK: Outlets
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var tfEmail: CustomTextField!
    @IBOutlet weak var tfURL: CustomTextField!
    @IBOutlet weak var tfPassword: CustomTextField!
    
    var isUpdate = false
    var myUser: [User]? {didSet {}}
    
   var maskedPasswordChar: String = "●"
   var passwordText: String = ""
   var isSecureTextEntry: Bool = true {
       didSet {
           let selectedTextRange = tfPassword.selectedTextRange
           tfPassword.text = isSecureTextEntry ? String(repeating: maskedPasswordChar, count: passwordText.count) : passwordText
           tfPassword.selectedTextRange = selectedTextRange
       }
   }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == tfPassword {
            //update password string
            if let swiftRange = Range(range, in: passwordText) {
                passwordText = passwordText.replacingCharacters(in: swiftRange, with: string)
            } else {
                passwordText = string
            }

            //replace textField text with masked password char
            textField.text =  isSecureTextEntry ? String(repeating: maskedPasswordChar, count: passwordText.count) : passwordText

            //handle cursor movement
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: range.location + string.utf16.count) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            return false
        }
        return true
    }
    
    //MARK:- View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        clearDB()
        
        tfPassword.delegate = self
        
        self.setupView()
    }
    
    func clearDB() {
        AutoTimeTrack().clearObj()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    
    //MARK:- Setup View
    func setupView() {
        if self.isUpdate{
            self.btnLogin.setTitle("Update", for: .normal)
            self.btnMenu.isHidden = false
        }else{
            self.btnLogin.setTitle("Login", for: .normal)
            self.btnMenu.isHidden = true
        }
        
        
        
//        tfURL.text = "support.portlr.dk"
//        tfEmail.text = "ss@bluedock.dk"
//        tfPassword.text = "Bluedock2021"
        
    }
    
    //MARK:- Utility Methods
    func shoDrawer(){
        let drawerController                        = KYDrawerController.init(drawerDirection: KYDrawerController.DrawerDirection.left, drawerWidth: 288)
        drawerController.mainViewController         = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationVC") as! TimeRegistrationController
        drawerController.drawerViewController       = self.storyboard?.instantiateViewController(withIdentifier: "MenuVC") as! MenuViewController
        
        let nav                     = UINavigationController(rootViewController: drawerController)
        nav.navigationBar.isHidden  = true
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: false, completion: nil)
    }
    //MARK:- Button Action
    
    @IBAction func btnLoginAction(_ sender: Any) {
        
        if !self.isUpdate{
            if AppUtility!.isEmpty(self.tfURL.text!){
                AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("validation_empty_URL", comment: ""), delegate: self)
                return
            }
            if AppUtility!.isEmpty(self.tfEmail.text!){
                AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("validation_empty_email", comment: ""), delegate: self)
                return
            }
            if !AppUtility!.isEmail(self.tfEmail.text!){
                AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("validation_valid_email", comment: ""), delegate: self)
                return
            }
            if AppUtility!.isEmpty(passwordText){
                AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("validation_empty_password", comment: ""), delegate: self)
                return
            }
            self.view.endEditing(true)
            self.callLoginAPI()
        }else{
            
        }
    }
    @IBAction func btnMenuAction(_ sender: Any) {
        if let drawerController = self.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    //MARK: API Methods
    func callLoginAPI(){
        if AppUtility!.connected() == false{
            AppUtility?.displayAlert(title: NSLocalizedString("no_network_alert_title", comment: ""), messageText: NSLocalizedString("no_network_alert_description", comment: ""), delegate: self)
            return
        }
        
        var url = self.tfURL.text!
        if !url.contains("https://") {
            url = "https://" + url
        }
        
        APIHandler.sharedInstance.loginUser(url: url, email: self.tfEmail.text!, password: passwordText, completionHandler: { (isSuccess, response) in
            if isSuccess {
                print(response)
                let success = response!["success"] as! Bool
                if success{
                    //self.shoDrawer()
                    let userObject = response!["result"] as! NSDictionary
                    let usr = User()
                    usr.userId = "\(userObject["userId"] as! Int)"
                    usr.email = self.tfEmail.text!
                    let secret = userObject["apiSecret"] as? String ?? ""
                    self.callGetTokenAPI(key: userObject["apiKey"] as! String, secret: secret, usr: usr)
                }else{
                    AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: "Information entered is incorrect!", delegate: self)
                    //response!["error"] as! String
                }
            }else{
                AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
            }
        })
    }
    
    func callGetTokenAPI(key:String,secret:String,usr:User){
        if AppUtility!.connected() == false{
            AppUtility?.displayAlert(title: NSLocalizedString("no_network_alert_title", comment: ""), messageText: NSLocalizedString("no_network_alert_description", comment: ""), delegate: self)
            return
        }
        APIHandler.sharedInstance.getTokenKey(apiKey: key, apiSecret: secret) { (isSuccess, response) in
            if isSuccess {
                print(response)
                let success = response!["success"] as! Bool
                if success{
                    AppUtility?.saveObject(obj: response!["result"] as! String, forKey: strToken)
                    self.myUser = [usr]
                    if User.saveUserToArchive(user: self.myUser!){
                        self.shoDrawer()
                    }
                }else{
                    AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: "Information entered is incorrect!", delegate: self)
                }
            }else{
                AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
            }
        }
    }
    
    //MARK:- DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
    
    
    //MARK:- View Life Cycle End here...
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
