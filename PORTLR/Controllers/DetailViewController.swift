//
//  DetailViewController.swift
//  PORTLR
//
//  Created by Hunain on 21/05/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    //MARK: Outlets
    @IBOutlet weak var tblCallDetail: UITableView!
    @IBOutlet weak var btnRegister: UIButton!
    
    var arrTitles = ["Company Name:","Date:","Start Time:","End Time:","Call Duration:"]
    var arrValues = [String]() //["Unknown","Null","18-May-2019","23:36:28","23:36:43","15s"]
    var objCall = Call()
    var arrNames = [[String:Any]]()
    var arrProjects = [[String:Any]]()
    
    var myUser: [User]? {didSet {}}
    var myCall: [Call]? {didSet {}}
    
    //MARK:- View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupView()
    }
    
    //MARK:- Setup View
    func setupView() {
        self.tblCallDetail.rowHeight = 50
        self.tblCallDetail.tableFooterView = UIView()
        self.setCallData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.setCompanyData), name:NSNotification.Name("CompanyData") , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setProjectData), name:NSNotification.Name("ProjectData") , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setCallerName), name:NSNotification.Name("CallerName") , object: nil)
    }
    
    //MARK:- Utility Methods
    @objc func setCallerName(notify:Notification){
        let callerName = notify.object as! String
        self.objCall.callerName = callerName
        //let callID = self.objCall.callId
        self.setCallData()
        
        /*self.myCall = Call.readCallFromArchive()
        for obj in self.myCall!{
            if obj.callId == callID{
                obj.callerName = callerName
                if Call.saveCallToArchive(call: self.myCall!){
                    self.myCall = Call.readCallFromArchive()
                }
                break
            }
        }*/
    }
    func showActionSheet(){
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionPhoneBook = UIAlertAction(title: "Select from Phonebook", style: .default) { (ac:UIAlertAction) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactsVC") as! ContactsViewController
            self.present(vc, animated: true, completion: nil)
        }
        let actionunknown = UIAlertAction(title: "Unknown Number", style: .default) { (ac:UIAlertAction) in
            self.objCall.callerName = "Unknown"
            let callID = self.objCall.callId
            self.setCallData()
            
            self.myCall = Call.readCallFromArchive()
            for obj in self.myCall!{
                if obj.callId == callID{
                    obj.callerName = "Unknown"
                    if Call.saveCallToArchive(call: self.myCall!){
                        self.myCall = Call.readCallFromArchive()
                    }
                    break
                }
            }
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (ac:UIAlertAction) in
            
        }
        sheet.addAction(actionPhoneBook)
        sheet.addAction(actionunknown)
        sheet.addAction(actionCancel)
        self.present(sheet, animated: true, completion: nil)
    }
    func showContactList(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactsVC") as! ContactsViewController
        self.present(vc, animated: true, completion: nil)
    }
    @objc func setCompanyData(notify:Notification){
        let data = notify.object as! [String]
        let name = data[1]
        self.arrValues[0] = name
        self.objCall.companyId = data[0]
        self.tblCallDetail.reloadData()
    }
    @objc func setProjectData(notify:Notification){
        let projectId = notify.object as! String
        print(projectId)
        self.callTimeSheetAPI(projectID: projectId)
    }
    
    func setCallData(){
        var strName = "Not Available"
        if self.objCall.callerName != nil{
            strName = self.objCall.callerName!
        }
        var strCompanyName = "Select Name ⌄"
        if self.objCall.companyName != nil{
            strCompanyName = self.objCall.companyName
        }
        //var clientStatus = "0"
        if self.objCall.clientStatus != nil{
            self.tblCallDetail.isUserInteractionEnabled = false
            self.btnRegister.setTitle("Time Registered Successfully", for: .normal)
        }else{
            self.tblCallDetail.isUserInteractionEnabled = true
            self.btnRegister.setTitle("Register Time", for: .normal)
        }
        self.arrValues = [strCompanyName,self.changeDateFormat(strDate: self.objCall.callDate, format: "dd-MMM-yyyy"),self.changeTimeFormat(strTime: objCall.callStartTime),self.changeTimeFormat(strTime: objCall.callEndTime),objCall.duration]
        self.tblCallDetail.reloadData()
    }
    
    func changeTimeFormat(strTime:String) -> String{
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let initialTime = timeFormatter.date(from: strTime)
        let timeFormatter2 = DateFormatter()
        timeFormatter2.dateFormat = "HH:mm:ss"
        let finalTime = timeFormatter2.string(from: initialTime!)
        return finalTime
    }
    func changeDateFormat(strDate:String,format:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let initialDate = dateFormatter.date(from: strDate)
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = format
        let finalDate = dateFormatter2.string(from: initialDate!)
        return finalDate
    }
    func getHoursDetail() -> [String]{
        let array = self.objCall.duration.components(separatedBy: ":")
        print(array)
        var hours = ""
        if array.count == 1{
            //Seconds
            let resultSec = array[0].filter("01234567890".contains)
            hours = "0.0\(resultSec)"
        }
        if array.count == 2{
            //Min & Seconds
            let resultSec = array[1].filter("01234567890".contains)
            let resultMin = array[0].filter("01234567890".contains)
            hours = "0.\(resultMin)\(resultSec)"
        }
        if array.count == 3{
            //Hours Min & Seconds
            let resultSec = array[2].filter("01234567890".contains)
            let resultMin = array[1].filter("01234567890".contains)
            let resultHr = array[0].filter("01234567890".contains)
            hours = "\(resultHr).\(resultMin)\(resultSec)"
        }
        
        let roundVal = CGFloat((hours as NSString).floatValue)
        var roundedHours = "0"
        if roundVal < 15.0{
            roundedHours = "15"
        }
        if roundVal > 15.0 && roundVal < 30.0{
            roundedHours = "30"
        }
        if roundVal > 30.0 && roundVal < 45.0{
            roundedHours = "45"
        }
        if roundVal > 45.0 && roundVal < 60.0{
            roundedHours = "60"
        }
        return [hours,roundedHours]
    }
    //MARK:- Button Action
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnRegisterAction(_ sender: Any) {
        //self.navigationController?.popViewController(animated: true)
        if self.objCall.clientStatus != nil{
            AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("time_already_registered_sucessfully", comment: ""), delegate: self)
        }else{
            if self.arrValues[1] == "Select Name ⌄"{
                AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("validation_select_company_name", comment: ""), delegate: self)
            }else{
                self.callGetProjectsAPI(clientID: self.objCall.companyId)
            }
        }
    }
    
    //MARK: API Methods
    func callGetCompnyNamesAPI(){
        self.arrNames.removeAll()
        if AppUtility!.connected() == false{
            AppUtility?.displayAlert(title: NSLocalizedString("no_network_alert_title", comment: ""), messageText: NSLocalizedString("no_network_alert_description", comment: ""), delegate: self)
            return
        }
        APIHandler.sharedInstance.getCompanyNames { (isSuccess, response) in
            if isSuccess {
                print(response)
                let success = response!["success"] as! Bool
                if success{
                    let resultObject = response!["result"] as! NSDictionary
                    let arrObjs = resultObject["items"] as! NSArray
                    
                        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
                        let sortedResults: NSArray = arrObjs.sortedArray(using: [descriptor]) as NSArray
                        print(sortedResults)
                        for obj in sortedResults as! [[String:Any]]{
                            self.arrNames.append(obj)
                        }
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CompanyNamesVC") as! CompanyNamesViewController
                        vc.arrCompanyNames = self.arrNames
                        vc.callID = self.objCall.callId
                        self.present(vc, animated: true, completion: nil)
                    
                    
                }else{
                    AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
                }
            }else{
                AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
            }
        }
    }
    
    func callGetProjectsAPI(clientID:String){
        self.myUser = User.readUserFromArchive()
        if AppUtility!.connected() == false{
            AppUtility?.displayAlert(title: NSLocalizedString("no_network_alert_title", comment: ""), messageText: NSLocalizedString("no_network_alert_description", comment: ""), delegate: self)
            return
        }
        
        APIHandler.sharedInstance.getProjectNames(clientID: clientID) { (isSuccess, response) in
            if isSuccess {
                print(response)
                let success = response!["success"] as! Bool
                if success{
                    let resultObject = response!["result"] as! NSDictionary
                    let arrObjs = resultObject["items"] as! NSArray
                    if arrObjs.count > 0{
                        let arrFinalProjects = NSMutableArray()
                        for var i in 0..<arrObjs.count{
                            let dict = arrObjs.object(at: i) as! NSDictionary
                            let arrTeams = dict.value(forKey: "team") as! NSArray
                            for var j in 0..<arrTeams.count{
                                let dictTeam = arrTeams.object(at: j) as! NSDictionary
                                let teamUserId = "\(dictTeam.value(forKey: "userId") as! Int)"
                                if teamUserId == self.myUser![0].userId{
                                    arrFinalProjects.add(dict)
                                    break
                                }
                            }
                        }
                        if arrFinalProjects.count > 0{
                            let descriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
                            let sortedResults: NSArray = arrFinalProjects.sortedArray(using: [descriptor]) as NSArray
                            print(sortedResults)
                            self.arrProjects.removeAll()
                            for obj in sortedResults as! [[String:Any]]{
                                self.arrProjects.append(obj)
                            }
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProjectNamesVC") as! ProjectNamesViewController
                            vc.arrProject = self.arrProjects
                            self.present(vc, animated: true, completion: nil)
                        }else{
                           AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("no_project_found", comment: ""), delegate: self)
                        }
                    }else{
                    AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("no_project_found", comment: ""), delegate: self)
                    }
                }else{
                    AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
                }
            }else{
               AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
            }
        }
    }
    
    func callTimeSheetAPI(projectID:String){
        self.myUser = User.readUserFromArchive()
        if AppUtility!.connected() == false{
            AppUtility?.displayAlert(title: NSLocalizedString("no_network_alert_title", comment: ""), messageText: NSLocalizedString("no_network_alert_description", comment: ""), delegate: self)
            return
        }
        let spent = "\(self.changeDateFormat(strDate: self.objCall.callDate, format: "yyyy-MM-dd")) \(self.changeTimeFormat(strTime: self.objCall.callStartTime))"
        let arrHoursValues = self.getHoursDetail()
        APIHandler.sharedInstance.setTimeSheet(projectID: projectID, userID: self.myUser![0].userId, endedAt: self.changeTimeFormat(strTime: self.objCall.callEndTime), hours: arrHoursValues[0], roundedHours: arrHoursValues[1], spentAt: spent, startedAt: self.changeTimeFormat(strTime: self.objCall.callStartTime)) { (isSuccess, response) in
            if isSuccess {
                print(response)
                let success = response!["success"] as! Bool
                if success{
                    self.objCall.clientStatus = "1"
                    self.setCallData()
                    NotificationCenter.default.post(name: NSNotification.Name("CallStatus"), object: self.objCall.callId)
                    AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("time_registered_sucessfully", comment: ""), delegate: self)
                    
                }else{
                    AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
                }
            }else{
                AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
            }
        }
        
    }
    //MARK:- DELEGATE METHODS
    
    //MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetails", for: indexPath) as! CallDetailTableViewCell
        cell.lblTitle.text = self.arrTitles[indexPath.row]
        cell.lblValue.text = self.arrValues[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*if indexPath.row == 0{
            if self.objCall.callerName != nil{
                self.showContactList()
            }else{
                self.showActionSheet()
            }
        }*/
        if indexPath.row == 0{
            self.callGetCompnyNamesAPI()
        }
    }
    
    
    
    //MARK:- View Life Cycle End here...
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
