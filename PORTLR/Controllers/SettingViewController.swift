//
//  SettingViewController.swift
//  PORTLR
//
//  Created by puma on 01.05.2020.
//  Copyright © 2020 Ranksol. All rights reserved.
//

import UIKit
import iOSDropDown
import CoreLocation

class SettingViewController: UIViewController {
    
//    var locationManager:CLLocationManager!
    
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var clockBtn: UIButton!
    
    
    @IBOutlet weak var callLogCheckBox: UIButton!
    @IBOutlet weak var activateCheckBox: UIButton!
    @IBOutlet weak var startPageCheckBox: UIButton!
    @IBOutlet weak var locationCheckBox: UIButton!
    
    
    // Weeks Button
    @IBOutlet weak var mBtn: UIButton!
    @IBOutlet weak var tueBtn: UIButton!
    @IBOutlet weak var wesBtn: UIButton!
    @IBOutlet weak var thuBtn: UIButton!
    @IBOutlet weak var friBtn: UIButton!
    @IBOutlet weak var satBtn: UIButton!
    @IBOutlet weak var sunBtn: UIButton!
    
    // dropdown list
    @IBOutlet weak var projectDD: DropDown!
    @IBOutlet weak var projectView: UIView!
    
    var myUser:[User]?{didSet{}}
    var projectList:[Project] = []
    var projectNameList: [String] = []
    let SELECT_STRING_PROJECT = "Select default project"
    
    // Typical time picker
    @IBOutlet weak var startTimerPicker: UITextField!
    @IBOutlet weak var endTimerPicker: UITextField!
    
    let startTimePic = UIDatePicker()
    let endTimePic = UIDatePicker()
    
    // Set new work location btn
    @IBOutlet weak var setlocationBtn: UIButton!
    @IBOutlet weak var activatedLocationLb: UILabel!
    @IBOutlet weak var phoneCallBtn: UIButton!
    
    var locationStr = ""
    var lat: Double = 0.0
    var lng: Double = 0.0
    var isSetLocation = false
    
    // confirm
    @IBOutlet weak var confirmBtn: UIButton!
    
    var autoTimeTrack = AutoTimeTrack()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestAlwaysAuthorization()
//
//        if CLLocationManager.locationServicesEnabled(){
//            locationManager.startUpdatingLocation()
//        }
        
        showPhoneCallLoggerBtn()
        loadUI()
        setUpProjectDD()
        setUpWeeks()
        setUpTimes()
        setUpSetLocationButton()
    }
    
    
    @IBAction func onClickConfirm(_ sender: Any) {
        
        if callLogCheckBox.tag == 1 {
            autoTimeTrack.isCallLogger = true
        } else { autoTimeTrack.isCallLogger = false }
        
        if activateCheckBox.tag == 1 {
            autoTimeTrack.isActive = true
        } else { autoTimeTrack.isActive = false }
        
        if startPageCheckBox.tag == 1 {
            autoTimeTrack.isSetStartPage = true
        } else { autoTimeTrack.isSetStartPage = false }
        
        if locationCheckBox.tag == 1 {
            autoTimeTrack.isLocation = true
        } else { autoTimeTrack.isLocation = false }
        
        if mBtn.tag == 1 {
            autoTimeTrack.workdays[0] = true
        } else { autoTimeTrack.workdays[0] = false }
        
        if tueBtn.tag == 1 {
            autoTimeTrack.workdays[1] = true
        } else { autoTimeTrack.workdays[1] = false }
        
        if wesBtn.tag == 1 {
            autoTimeTrack.workdays[2] = true
        } else { autoTimeTrack.workdays[2] = false }
        
        if thuBtn.tag == 1 {
            autoTimeTrack.workdays[3] = true
        } else { autoTimeTrack.workdays[3] = false }
        
        if friBtn.tag == 1 {
            autoTimeTrack.workdays[4] = true
        } else { autoTimeTrack.workdays[4] = false }
        
        if satBtn.tag == 1 {
            autoTimeTrack.workdays[5] = true
        } else { autoTimeTrack.workdays[5] = false }
        
        if sunBtn.tag == 1 {
            autoTimeTrack.workdays[6] = true
        } else { autoTimeTrack.workdays[6] = false }
        
        if !startTimerPicker.text!.isEmpty {
            autoTimeTrack.startTime = startTimePic.date
        }
        if !endTimerPicker.text!.isEmpty {
            autoTimeTrack.endTime = endTimePic.date
        }
        
        if isSetLocation {
            autoTimeTrack.workLocation = activatedLocationLb.text
            autoTimeTrack.lat = lat
            autoTimeTrack.lng = lng
        } else {
            if activatedLocationLb.text!.isEmpty {
                autoTimeTrack.workLocation = ""
                autoTimeTrack.lat = 0.0
                autoTimeTrack.lng = 0.0
            }
        }
        
        
        let selectedProjectName = projectDD.text
        
        if selectedProjectName == SELECT_STRING_PROJECT {
            autoTimeTrack.projectName = ""
            autoTimeTrack.projectID = ""
        } else {
            let selectedProject = self.projectList.filter{ $0.name == selectedProjectName }
            autoTimeTrack.projectID = String(selectedProject[0].userId)
            autoTimeTrack.projectName = selectedProjectName
        }
        
        // save changed data
        autoTimeTrack.saveObj()
        
        // register notifications
        autoTimeTrack.registerNotifications()
        
        let alert = UIAlertController(title: NSLocalizedString("alert_app_name", comment: ""), message: NSLocalizedString("registered_successfully", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            self.showPhoneCallLoggerBtn()
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func loadUI() {
        autoTimeTrack.loadObj()
        
        if autoTimeTrack.isActive {
            activateCheckBox.tag = 1
        }
        else {
            activateCheckBox.tag = 0
        }
        updateActivateBtn()
        
        if autoTimeTrack.isSetStartPage {
            startPageCheckBox.tag = 1
        }
        else {
            startPageCheckBox.tag = 0
        }
        updateStartPageBtn()
        
        if autoTimeTrack.isCallLogger {
            callLogCheckBox.tag = 1
        } else {
            callLogCheckBox.tag = 0
        }
        updateCallLogBtn()
        
        if autoTimeTrack.isLocation {
            locationCheckBox.tag = 1
        } else {
            locationCheckBox.tag = 0
        }
        updateLocationCheckBoxBtn()
        
        if autoTimeTrack.workdays[0] { mBtn.tag = 1} else { mBtn.tag = 0 }
        if autoTimeTrack.workdays[1] { tueBtn.tag = 1} else { tueBtn.tag = 0 }
        if autoTimeTrack.workdays[2] { wesBtn.tag = 1} else { wesBtn.tag = 0 }
        if autoTimeTrack.workdays[3] { thuBtn.tag = 1} else { thuBtn.tag = 0 }
        if autoTimeTrack.workdays[4] { friBtn.tag = 1} else { friBtn.tag = 0 }
        if autoTimeTrack.workdays[5] { satBtn.tag = 1} else { satBtn.tag = 0 }
        if autoTimeTrack.workdays[6] { sunBtn.tag = 1} else { sunBtn.tag = 0 }
        
    }
    
    func setUpWeeks() {
        setUpWeekBtn(btn: mBtn)
        setUpWeekBtn(btn: tueBtn)
        setUpWeekBtn(btn: wesBtn)
        setUpWeekBtn(btn: thuBtn)
        setUpWeekBtn(btn: friBtn)
        setUpWeekBtn(btn: satBtn)
        setUpWeekBtn(btn: sunBtn)
    }
    
    func setUpWeekBtn(btn: UIButton) {
        if btn.tag == 0 {
            btn.layer.borderWidth = 2
            btn.layer.cornerRadius = 4
            btn.layer.borderColor = COLOR_DEFAULT
            btn.layer.backgroundColor = COLOR_WHITE
            btn.setTitleColor(UIColor.init(cgColor: COLOR_DEFAULT), for: .normal)
        } else {
            btn.layer.borderWidth = 2
            btn.layer.cornerRadius = 4
            btn.layer.borderColor = COLOR_DEFAULT
            btn.layer.backgroundColor = COLOR_DEFAULT
            btn.setTitleColor(UIColor.init(cgColor: COLOR_WHITE), for: .normal)
        }
    }
    
    func clickedBtn(btn: UIButton) {
        if btn.tag == 0 {
            btn.tag = 1
        } else {
            btn.tag = 0
        }
        setUpWeekBtn(btn: btn)
    }
    
    @IBAction func onClickM(_ sender: Any) {
        clickedBtn(btn: mBtn)
    }
    
    @IBAction func onClickTue(_ sender: Any) {
        clickedBtn(btn: tueBtn)
    }
    
    @IBAction func onClickWes(_ sender: Any) {
        clickedBtn(btn: wesBtn)
    }
    
    @IBAction func onClickThu(_ sender: Any) {
        clickedBtn(btn: thuBtn)
    }
    
    @IBAction func onClickFri(_ sender: Any) {
        clickedBtn(btn: friBtn)
    }
    
    @IBAction func onCLickSat(_ sender: Any) {
        clickedBtn(btn: satBtn)
    }
    
    @IBAction func onClickSun(_ sender: Any) {
        clickedBtn(btn: sunBtn)
    }
    
    
    @IBAction func onClickActivate(_ sender: Any) {
        if activateCheckBox.tag == 0 {
            activateCheckBox.tag = 1
        } else {
            activateCheckBox.tag = 0
        }
        updateActivateBtn()
    }
    
    @IBAction func onClickStartPage(_ sender: Any) {
        if startPageCheckBox.tag == 0 {
            startPageCheckBox.tag = 1
        } else {
            startPageCheckBox.tag = 0
        }
        updateStartPageBtn()
    }
    
    @IBAction func onClickCallLog(_ sender: Any) {
        if callLogCheckBox.tag == 0 {
            callLogCheckBox.tag = 1
        } else {
            callLogCheckBox.tag = 0
        }
        updateCallLogBtn()
    }
    
    @IBAction func onClickLocationCheckBox(_ sender: Any) {
        if locationCheckBox.tag == 0 {
            locationCheckBox.tag = 1
        } else {
            locationCheckBox.tag = 0
        }
        updateLocationCheckBoxBtn()
    }
    
    func updateActivateBtn() {
        if activateCheckBox.tag == 1 {
            activateCheckBox.setImage(UIImage(named: "ic_check"), for: .normal)
        } else {
            activateCheckBox.setImage(UIImage(named: "ic_uncheck"), for: .normal)
        }
    }
    
    func updateStartPageBtn() {
        if startPageCheckBox.tag == 1 {
            startPageCheckBox.setImage(UIImage(named: "ic_check"), for: .normal)
        } else {
            startPageCheckBox.setImage(UIImage(named: "ic_uncheck"), for: .normal)
        }
    }
    
    func updateCallLogBtn() {
        if callLogCheckBox.tag == 1 {
            callLogCheckBox.setImage(UIImage(named: "ic_check"), for: .normal)
        } else {
            callLogCheckBox.setImage(UIImage(named: "ic_uncheck"), for: .normal)
        }
    }
    
    func updateLocationCheckBoxBtn() {
        if locationCheckBox.tag == 1 {
            locationCheckBox.setImage(UIImage(named: "ic_check"), for: .normal)
        } else {
            locationCheckBox.setImage(UIImage(named: "ic_uncheck"), for: .normal)
        }
    }
    
    @IBAction func onClickList(_ sender: Any) {
        
    }
    
    @IBAction func onClickClock(_ sender: Any) {
        
    }
    
    @IBAction func onClickLogout(_ sender: Any) {
        self.myUser = User.readUserFromArchive()
        self.myUser?.remove(at: 0)
        if User.saveUserToArchive(user: self.myUser!){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.isHidden = true
            appDelegate.window!.rootViewController = nav
        }
    }
    
    @IBAction func onClickSetting(_ sender: Any) {
        
    }
    
    func setUpProjectDD() {
    
        
        projectView.layer.borderColor = COLOR_TIME_REG
        projectView.layer.borderWidth = BORDER_WIDTH_TIME_REG
        projectView.layer.cornerRadius = RADIUS_TIME_REG
        
        projectDD.listHeight = 250
        
        if autoTimeTrack.projectName.isEmpty {
            projectDD.text = SELECT_STRING_PROJECT
        } else {
            projectDD.text = autoTimeTrack.projectName
        }
        
        projectDD.font = UIFont(name:"Montserrat-Light",size:15)
        
        myUser = User.readUserFromArchive()
        if (self.myUser != nil && self.myUser?.count != 0){
            let user = myUser![0]
            
            loadProjects(clientID: user.userId)
        }
    }
    
    func loadProjects(clientID: String) {
        APIHandler.sharedInstance.getProjectNames(clientID: clientID) { (isSuccess, response) in
                   if isSuccess {
                       let success = response!["success"] as! Bool
                       if success{
                            let resultObject = response!["result"] as! NSDictionary
                            let arrObjs = resultObject["items"] as! NSArray
                            for i in 0 ..< arrObjs.count {
                                let dict = arrObjs.object(at: i) as! NSDictionary
                                if dict["isActive"] as? Bool ?? false == true
                                {
                                    let project = Project()
                                    project.userId = dict["id"] as? Int
                                    project.name = dict["name"] as? String
                                    self.projectList.append(project)
                                    self.projectNameList.append(project.name)
                                }
                                
                            }
                        
                        self.projectDD.optionArray = self.projectNameList.sorted{ $0 < $1 }
                       }else{
                           AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
                       }
                   }else{
                      AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
                   }
               }
    }
    
    func setUpTimes() {
        let textColor: UIColor = #colorLiteral(red: 0.2969530523, green: 0.2969608307, blue: 0.2969566584, alpha: 1)
        
        if autoTimeTrack.isFirstTime {
            startTimerPicker.attributedPlaceholder = NSAttributedString(string: "Typical start time",
            attributes: [NSAttributedString.Key.foregroundColor: textColor])
            
            endTimerPicker.attributedPlaceholder = NSAttributedString(string: "Typical end time",
            attributes: [NSAttributedString.Key.foregroundColor: textColor])
        } else {
            startTimePic.date = autoTimeTrack.startTime
            updateTime(num: 1)
            endTimePic.date = autoTimeTrack.endTime
            updateTime(num: 2)
        }
        
        
        
        startTimerPicker.layer.borderColor = COLOR_TIME_REG
        startTimerPicker.layer.borderWidth = BORDER_WIDTH_TIME_REG
        startTimerPicker.layer.cornerRadius = RADIUS_TIME_REG
        
        endTimerPicker.layer.borderColor = COLOR_TIME_REG
        endTimerPicker.layer.borderWidth = BORDER_WIDTH_TIME_REG
        endTimerPicker.layer.cornerRadius = RADIUS_TIME_REG
        
        showStartTimePicker()
        showEndTimePicker()
    }
    
    func showStartTimePicker(){
              //Formate Date
              startTimePic.datePickerMode = .time
              
              //ToolBar
              let toolbar = UIToolbar()
              toolbar.sizeToFit()
              let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneStartTimePicker));
              let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
              let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelStartTimePicker));
              
              toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
              
              startTimerPicker.inputAccessoryView = toolbar
              startTimerPicker.inputView = startTimePic
            
    //        startTimePic.date = DateTimeUtils.share.getStringToTime(time: "09:00:00")
    //        updateTime(num: 1)
            
          }
        
        func showEndTimePicker(){
                 //Formate Date
                 endTimePic.datePickerMode = .time
                 
                 //ToolBar
                 let toolbar = UIToolbar()
                 toolbar.sizeToFit()
                 let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneEndTimePicker));
                 let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
                 let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEndTimePicker));
                 
                 toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
                 
                 endTimerPicker.inputAccessoryView = toolbar
                 endTimerPicker.inputView = endTimePic
             }
        
        @objc func doneStartTimePicker(){
            
            updateTime(num: 1)
            self.view.endEditing(true)
        }
        
        @objc func cancelStartTimePicker(){
            self.view.endEditing(true)
        }
        
        @objc func doneEndTimePicker(){
              
            updateTime(num: 2)
              self.view.endEditing(true)
          }
          
          @objc func cancelEndTimePicker(){
              self.view.endEditing(true)
          }
    
    func updateTime(num: Int) {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    if num == 1 {
        startTimerPicker.text = formatter.string(from: startTimePic.date)
    } else {
          endTimerPicker.text = formatter.string(from: endTimePic.date)
    }
    
    if startTimerPicker.text!.isEmpty || endTimerPicker.text!.isEmpty {
        return
    }
    
    let time1 = startTimePic.date
    let time2 = endTimePic.date
    
    let interval = time2.timeIntervalSince(time1)
    
    if interval <= 0 {
        let alert = UIAlertController(title: "Warning", message: "End Time should be greater than Start Time", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               self.present(alert, animated: true, completion: nil)
        return
    }
    }
    
    func setUpSetLocationButton() {
        setlocationBtn.layer.cornerRadius = RADIUS_TIME_REG
        confirmBtn.layer.cornerRadius = RADIUS_TIME_REG
        
        activatedLocationLb.layer.borderColor = COLOR_DEFAULT
        activatedLocationLb.layer.cornerRadius = 8
        activatedLocationLb.layer.borderWidth = 1.0
        
        activatedLocationLb.text = autoTimeTrack.workLocation
    }
    
    @IBAction func onClickSetLocation(_ sender: Any) {
        isSetLocation = true
        self.locationStr = CurrentLocationManager.address
        self.lat = CurrentLocationManager.lat
        self.lng = CurrentLocationManager.lng
        self.activatedLocationLb.text = self.locationStr
        
        print("current location")
        print(self.lat)
        print(self.lng)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation

//        print("user latitude = \(userLocation.coordinate.latitude)")
//        print("user longitude = \(userLocation.coordinate.longitude)")

        lat = userLocation.coordinate.latitude
        lng = userLocation.coordinate.longitude

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks
            if placemark != nil && placemark!.count>0{
                let placemark = placemarks![0]
                print(placemark.locality!)
                print(placemark.administrativeArea!)
                print(placemark.country!)

                self.locationStr = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
//                self.locationManager.stopUpdatingLocation()
            }
        }
    }
    
    @IBAction func onClickQCallLog(_ sender: Any) {
        showAlert(msg: "question_call_logger")
    }
    
    @IBAction func onClickQNotification(_ sender: Any) {
        showAlert(msg: "question_check")
    }
    
    @IBAction func onClickQTimer(_ sender: Any) {
        showAlert(msg: "question_set_timer")
    }
    
    @IBAction func onClickQLocation(_ sender: Any) {
        showAlert(msg: "question_location")
    }
    
    @IBAction func onClickQWorkDay(_ sender: Any) {
        showAlert(msg: "question_workday")
    }
    
    func showAlert(msg: String) {
        
        let alert = UIAlertController(title: NSLocalizedString("alert_app_name", comment: ""), message: NSLocalizedString(msg, comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showPhoneCallLoggerBtn() {
        if AutoTimeTrack().isCheckCallLogger() {
            phoneCallBtn.isHidden = false
        } else {
            phoneCallBtn.isHidden = true
        }
    }
    
}
