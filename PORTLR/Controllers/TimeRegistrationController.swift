//
//  TimeRegistrationController.swift
//  PORTLR
//
//  Created by puma on 06.04.2020.
//  Copyright © 2020 Ranksol. All rights reserved.
//

import UIKit
import iOSDropDown
import CallKit

class TimeRegistrationController: UIViewController {
    
    
    @IBOutlet weak var projectPView: UIView!
    @IBOutlet weak var taskPView: UIView!
    @IBOutlet weak var notfPView: UIView!
    @IBOutlet weak var resultPView: UIView!
    
    
    @IBOutlet weak var projectDD: DropDown!
    @IBOutlet weak var taskDD: DropDown!
    
    
    @IBOutlet weak var notesTf: UITextField!
    
    @IBOutlet weak var startTimerPicker: UITextField!
    @IBOutlet weak var endTimerPicker: UITextField!
    @IBOutlet weak var resultTf: UITextField!
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var clockBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    
    @IBOutlet weak var quistionBtn: UIImageView!
    
    @IBOutlet weak var newregBtn: UIButton!
    @IBOutlet weak var phonecallBtn: UIButton!
    
    
    var resultStr: String = ""
    
    
//    let SELECT_STRING = "--- Select ---"
    let SELECT_STRING_PROJECT = "Project"
    let SELECT_STRING_TASK = "Task"
    let PHONE_CONVERSATION = "Phone Conversation"
    let STR_REGISTERED = "REGISTERED"
    
    var projectList:[Project] = []
    var projectNameList: [String] = []
    var taskList:[Task] = []
    var taskNameList: [String] = []
    
    var myUser:[User]?{didSet{}}
    let startTimePic = UIDatePicker()
    let endTimePic = UIDatePicker()
    
    var currentUserId = ""
    
    var selectedLog: TimeLog? = nil
    var selectedCall: Call? = nil
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
        showPhoneCallLoggerBtn()
        
        setUpViews()
        
        projectDD.listHeight = 250
        taskDD.listHeight = 250
        
        showStartTimePicker()
        showEndTimePicker()
        
        myUser = User.readUserFromArchive()
        if (self.myUser != nil && self.myUser?.count != 0){
            let user = myUser![0]
            
            loadProjects(clientID: user.userId)
        }
        
        projectDD.text = SELECT_STRING_PROJECT
        taskDD.text = SELECT_STRING_TASK
        
        projectDD.didSelect{(selectedText , index ,id) in
            self.projectDD.text = selectedText
            self.updateTaskList()
        }
        
        loadLog()
        loadCall()
     }
    
    func setUpViews() {
        
        let normalColor: UIColor = #colorLiteral(red: 0.1129845455, green: 0.4494044185, blue: 0.747171104, alpha: 1)
        let textColor: UIColor = #colorLiteral(red: 0.2969530523, green: 0.2969608307, blue: 0.2969566584, alpha: 1)
        
        projectPView.layer.borderColor = COLOR_TIME_REG
        projectPView.layer.borderWidth = BORDER_WIDTH_TIME_REG
        projectPView.layer.cornerRadius = RADIUS_TIME_REG
        
        taskPView.layer.borderColor = COLOR_TIME_REG
        taskPView.layer.borderWidth = BORDER_WIDTH_TIME_REG
        taskPView.layer.cornerRadius = RADIUS_TIME_REG
        
        notfPView.layer.borderColor = COLOR_TIME_REG
        notfPView.layer.borderWidth = BORDER_WIDTH_TIME_REG
        notfPView.layer.cornerRadius = RADIUS_TIME_REG
        
        resultPView.layer.borderColor = COLOR_TIME_REG
        resultPView.layer.borderWidth = BORDER_WIDTH_TIME_REG
        resultPView.layer.cornerRadius = RADIUS_TIME_REG
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: self.notesTf.frame.height))
        notesTf.leftView = paddingView
        notesTf.leftViewMode = UITextField.ViewMode.always
        
        notesTf.attributedPlaceholder = NSAttributedString(string: "Comment",
                                                           attributes: [NSAttributedString.Key.foregroundColor: textColor])
        
        resultTf.attributedPlaceholder = NSAttributedString(string: "00:00",
        attributes: [NSAttributedString.Key.foregroundColor: normalColor])
        
        startTimerPicker.attributedPlaceholder = NSAttributedString(string: "Start",
        attributes: [NSAttributedString.Key.foregroundColor: textColor])
        
        endTimerPicker.attributedPlaceholder = NSAttributedString(string: "End",
        attributes: [NSAttributedString.Key.foregroundColor: textColor])
        
        startTimerPicker.layer.borderColor = COLOR_TIME_REG
        startTimerPicker.layer.borderWidth = BORDER_WIDTH_TIME_REG
        startTimerPicker.layer.cornerRadius = RADIUS_TIME_REG
        
        endTimerPicker.layer.borderColor = COLOR_TIME_REG
        endTimerPicker.layer.borderWidth = BORDER_WIDTH_TIME_REG
        endTimerPicker.layer.cornerRadius = RADIUS_TIME_REG
        
        cancelBtn.layer.cornerRadius = RADIUS_TIME_REG
        addBtn.layer.cornerRadius = RADIUS_TIME_REG
        
        projectDD.font = UIFont(name:"Montserrat-Light",size:15)
        taskDD.font = UIFont(name:"Montserrat-Light",size:15)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
           quistionBtn.isUserInteractionEnabled = true
           quistionBtn.addGestureRecognizer(tapGestureRecognizer)
        
        resultTf.keyboardType = .numberPad
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
       AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("question_image_meaning", comment: ""), delegate: self)
    }
    
    
    func loadLog() {
        if self.selectedLog == nil {
            return
        }
        
        addBtn.setTitle("Update", for: .normal)
        hiddenBtns()
        
        notesTf.text = self.selectedLog?.comment
        if self.selectedLog?.startAt != nil && !self.selectedLog!.startAt.isEmpty {
            startTimePic.date = DateTimeUtils.share.getStringToTime(time: self.selectedLog!.startAt!)
            updateTime(num: 1)
        }
        
        if self.selectedLog?.endAt != nil && !self.selectedLog!.endAt.isEmpty {
            endTimePic.date = DateTimeUtils.share.getStringToTime(time: self.selectedLog!.endAt!)
            updateTime(num: 2)
        }
        
        if self.selectedLog?.hours != nil {
//            self.resultTf.text = String(self.selectedLog!.hours!).replacingOccurrences(of: ".", with: ":")
            self.resultTf.text = DateTimeUtils.share.getLocalTimeFromServer(time: self.selectedLog!.hours!)
        }
        
        if self.selectedLog?.projectId == nil {
            return
        }
        
        self.projectDD.text = self.selectedLog?.projectName
        self.updateTaskList(projectId: self.selectedLog?.projectId)
        
        if self.selectedLog?.taskId == nil {
            return
        }
        
        self.taskDD.text = self.selectedLog?.taskName
    }
    
    func loadCall() {
        if self.selectedCall == nil {
            return
        }
        
        hiddenBtns()
        
        notesTf.text = PHONE_CONVERSATION
        
        if self.selectedCall?.callStartTime != nil && !self.selectedCall!.callStartTime.isEmpty {
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM/dd/yyyy HH:mm:ss"
            let dateStart = dateFormat.date(from: selectedCall!.callStartTime!)
            
            startTimePic.date = dateStart ?? Date()
            updateTime(num: 1)
        }
        
        if self.selectedCall?.callEndTime != nil && !self.selectedCall!.callEndTime.isEmpty {
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM/dd/yyyy HH:mm:ss"
            let dateEnd = dateFormat.date(from: selectedCall!.callEndTime!)
            
            endTimePic.date = dateEnd ?? Date()
            updateTime(num: 2)
        }
        
        if self.selectedCall?.projectId == nil {
            return
        }
        
        addBtn.titleLabel?.font = UIFont(name: "Montserrat SemiBold", size: 10)
        cancelBtn.titleLabel?.font = UIFont(name: "Montserrat SemiBold", size: 10)
        
        addBtn.setTitle(STR_REGISTERED, for: .normal)
        
        self.projectDD.text = self.selectedCall?.projectName
        self.updateTaskList(projectId: self.selectedCall?.projectId)
        
        if self.selectedCall?.taskId == nil {
            return
        }
        
        self.taskDD.text = self.selectedCall?.taskName
        
    }
    
    func updateTaskList(projectId: Int? = nil) {
        self.taskDD.text = SELECT_STRING_TASK
        self.taskDD.optionArray = []
        self.taskNameList = []
        self.taskList = []
        
        let selectedProjectName = projectDD.text
        
        if selectedProjectName == SELECT_STRING_PROJECT {
            return
        }
        
        if projectId != nil {
            self.loadTasks(projectID: String(projectId!))
            return
        }
        
        let selectedProject = self.projectList.filter{ $0.name == selectedProjectName }
        let selectedProjectId = selectedProject[0].userId
        
        self.loadTasks(projectID: String(selectedProjectId!))
    
    }
    
    func loadProjects(clientID: String) {
        self.currentUserId = clientID
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
    
    func loadTasks(projectID: String) {
        print(self.currentUserId, projectID)
        APIHandler.sharedInstance.getTasks(clientID: self.currentUserId, projectID: projectID) { (isSuccess, response) in
               if isSuccess {
                   let success = response!["success"] as! Bool
                   if success{
                        let resultObject = response!["result"] as! NSDictionary
                        let arrObjs = resultObject["items"] as! NSArray
                        for i in 0 ..< arrObjs.count {
                            let dict = arrObjs.object(at: i) as! NSDictionary
                            if dict["isClosed"] as? Bool ?? true == false {
                                let task = Task()
                                task.id = dict["id"] as? Int
                                task.title = dict["title"] as? String
                                self.taskList.append(task)
                                self.taskNameList.append(task.title)
                            }
                        }
                    self.taskDD.optionArray = self.taskNameList.sorted{ $0 < $1 }
                   }else{
                       AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
                   }
               }else{
                  AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
               }
           }
    }
    
    func coverResult() {
        
        if self.resultStr.contains(":") {
            return
        }
        
        if self.resultStr.contains(".") || self.resultStr.contains(",") || self.resultStr.contains(";") {
            return
        }
        
        if !self.resultStr.isNumber {
            return
        }
        
        if self.resultStr.count == 1 {
            self.resultStr = self.resultStr + ":00"
            return
        }
        if self.resultStr.count == 2 {
            self.resultStr = "\(resultStr.first!):\(resultStr.last!)"
            return
        }
        if self.resultStr.count == 3 {
            let startIndex = resultStr.index(resultStr.startIndex, offsetBy: 1)
            let endIndex = resultStr.index(startIndex, offsetBy: 2)
            self.resultStr = "\(resultStr.first!):\(resultStr[startIndex..<endIndex])"
            return
        }
        if self.resultStr.count == 4 {
            let startIndex = resultStr.index(resultStr.startIndex, offsetBy: 2)
            let endIndex = resultStr.index(startIndex, offsetBy: 2)
            self.resultStr = "\(resultStr[resultStr.startIndex..<startIndex]):\(resultStr[startIndex..<endIndex])"
            return
        }
    }
    
    @IBAction func onAdd(_ sender: Any) {
        
        if selectedCall != nil {
            if selectedCall?.projectId != nil {
                
                AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("call_log_already_registered", comment: ""), delegate: self)
                
                return
            }
        }
        
        let selectedProjectName = projectDD.text
        let selectedTaskName = taskDD.text
        self.resultStr = resultTf.text!
        coverResult()
        
        
        if selectedProjectName == SELECT_STRING_PROJECT {
            AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("select_project", comment: ""), delegate: self)
            return
        }

//        if selectedTaskName == SELECT_STRING {
//            AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("select_task", comment: ""), delegate: self)
//            return
//        }
        
        
        
        if self.resultStr.isEmpty {
            AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("select_time", comment: ""), delegate: self)
            return
        }

        let selectedProject = self.projectList.filter{ $0.name == selectedProjectName }
        var selectedProjectId: String? = nil
        if !selectedProject.isEmpty {
            selectedProjectId = String(selectedProject[0].userId)
        }

        let selectedTask = self.taskList.filter{ $0.title == selectedTaskName }
        
        var selectedTaskId: String? = nil
        if !selectedTask.isEmpty {
            selectedTaskId = String(selectedTask[0].id)
        }
        
    //
        
        var spent = "\(self.changeDateFormat(strDate: self.startTimePic.date, format: "yyyy-MM-dd"))T\(self.changeTimeFormat(strTime: self.startTimePic.date)).000Z"
        let arrHoursValues = self.getHoursDetail()
        
        if arrHoursValues.count == 0 {
            AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("select_time_correct", comment: ""), delegate: self)
            return
        }
        
        var startAt: String = "09:00:00"
        if !self.startTimerPicker.text!.isEmpty {
            startAt = self.changeTimeFormatSpe(strTime: self.startTimePic.date)
        }
        
        var endAt: String = ""
        if !self.endTimerPicker.text!.isEmpty {
            endAt = self.changeTimeFormatSpe(strTime: self.endTimePic.date)
        } else {
            var startT = DateTimeUtils.share.getStringToTime(time: "09:00:00")
            let interval = DateTimeUtils.share.getIntervalTime(timeStr: self.resultStr)
            startT.addTimeInterval(TimeInterval(interval))
            endAt = self.changeTimeFormatSpe(strTime: startT)
        }
        
        var timeSheetId = 0
        if selectedLog != nil {
            timeSheetId = selectedLog!.timesheetId
            if selectedTaskId == nil {
                if selectedLog!.taskId != nil {
                    selectedTaskId = String(selectedLog!.taskId)
                }
            }
            
            if selectedLog!.spentAt != nil {
                spent = selectedLog!.spentAt
            }
        }
        
        APIHandler.sharedInstance.newSetTimeSheet(timeSheetId: timeSheetId, projectID: selectedProjectId ?? "", taskID: selectedTaskId ?? "", userID: self.myUser![0].userId, endedAt: endAt, hours: DateTimeUtils.share.getServerTimeForPost(timeStr: arrHoursValues[0]), roundedHours: DateTimeUtils.share.getServerTimeForPost(timeStr: arrHoursValues[1]), spentAt: spent, startedAt: startAt, notes: notesTf.text!) { (isSuccess, response) in
            if isSuccess {
                let success = response!["success"] as! Bool
                if success{

                    if self.selectedCall != nil {
                        let alert = UIAlertController(title: NSLocalizedString("alert_app_name", comment: ""), message: NSLocalizedString("call_registered_sucessfully", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            
                            self.dismissVCWithCallLog(
                                projectId: selectedProjectId,
                                taskId: selectedTaskId,
                                projectName: selectedProjectName,
                                taskName: selectedTaskName
                            )
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if self.selectedLog != nil {
                        let alert = UIAlertController(title: NSLocalizedString("alert_app_name", comment: ""), message: NSLocalizedString("time_updated_sucessfully", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            
                            self.dismissVC()
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        let alert = UIAlertController(title: NSLocalizedString("alert_app_name", comment: ""), message: NSLocalizedString("time_registered_sucessfully", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            self.clearForm()
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }

                }else{
                    AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
                }
            }else{
                AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
            }
        }
        
    }
    
    func clearForm() {
        projectDD.text = SELECT_STRING_PROJECT
        taskDD.text = SELECT_STRING_TASK
        projectDD.selectedIndex = -1
        taskDD.selectedIndex = -1
        resultTf.text = ""
        notesTf.text = ""
        startTimerPicker.text = ""
        endTimerPicker.text = ""
    }
    
    
    @IBAction func onCancel(_ sender: Any) {
//        self.performSegue(withIdentifier: "showActivityId", sender: self)
        
        if self.selectedCall != nil {
            self.dismissVC()
            return
        }
        
        if self.selectedLog == nil {
            self.clearForm()
            return
        }
        
        self.dismissVC()
        
        
    }
    
    func dismissVCWithCallLog(
    projectId: String?,
    taskId: String?,
    projectName: String?,
    taskName: String?) {
        
        if projectId != nil {
            selectedCall?.projectId = Int(projectId!)
        } else {
            selectedCall?.projectId = nil
        }
        if taskId != nil {
            selectedCall?.taskId = Int(taskId!)
        } else {
            selectedCall?.taskId = nil
        }
        selectedCall?.projectName = projectName
        selectedCall?.taskName = taskName
        Call.saveCall(call: selectedCall!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func dismissVC() {
        self.dismiss(animated: true, completion: nil)
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
        
        let hour = Int(interval / 3600)
        let minute = Int(interval.truncatingRemainder(dividingBy: 3600) / 60)
        
        resultTf.text = "\(hour):\(minute)"
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
    
    func changeTimeFormat(strTime:Date) -> String{
        let timeFormatter2 = DateFormatter()
        timeFormatter2.dateFormat = "HH:mm:ss"
        let finalTime = timeFormatter2.string(from: strTime)
        return finalTime
    }
    func changeTimeFormatSpe(strTime: Date) -> String {
        let timeFormatter2 = DateFormatter()
             timeFormatter2.dateFormat = "HH:mm:ss"
             let finalTime = timeFormatter2.string(from: strTime)
        return "\(finalTime).0000000"
    }
    func changeDateFormat(strDate:Date ,format:String) -> String{
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = format
        let finalDate = dateFormatter2.string(from: strDate)
        return finalDate
    }
    func getHoursDetail() -> [String]{
        let intervalInt = DateTimeUtils.share.getIntervalTime(timeStr: self.resultStr)
        if intervalInt == -1 {
            return []
        }
        let interval = Double(intervalInt)
        let hours = Int(interval / 3600)
        let minute = Int(interval.truncatingRemainder(dividingBy: 3600) / 60)
        
        let roundVal = Float(minute)
        var roundedHours = "0"
        if roundVal < 15.0{
            roundedHours = "\(hours).15"
        }
        if roundVal > 15.0 && roundVal < 30.0{
            roundedHours = "\(hours).30"
        }
        if roundVal > 30.0 && roundVal < 45.0{
            roundedHours = "\(hours).45"
        }
        if roundVal > 45.0 && roundVal < 60.0{
            roundedHours = "\(hours + 1).00"
        }
        return [self.resultStr.replacingOccurrences(of: ":", with: "."),roundedHours]
    }
    
    @IBAction func onLogout(_ sender: Any) {
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
    
    func hiddenBtns() {
        logoutBtn.isHidden = true
        listBtn.isHidden = true
        clockBtn.isHidden = true
        settingBtn.isHidden = true
        newregBtn.isHidden = true
        phonecallBtn.isHidden = true
    }
    
    func showPhoneCallLoggerBtn() {
        if AutoTimeTrack().isCheckCallLogger() {
            phonecallBtn.isHidden = false
        } else {
            phonecallBtn.isHidden = true
        }
    }
    
}

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
