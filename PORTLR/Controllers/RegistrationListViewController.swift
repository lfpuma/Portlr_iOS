//
//  RegistrationListViewController.swift
//  PORTLR
//
//  Created by puma on 07.04.2020.
//  Copyright © 2020 Ranksol. All rights reserved.
//

import UIKit

class RegistrationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditBtnTapDelegate {
    
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateTf: UITextField!
    
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var sumLb: UILabel!
    
    var selectedLog: TimeLog? = nil
    
//    var sheetList: [TimeLog] = []
    var filteredSheetList: [TimeLog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        showDatePicker()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 114
        
        setupViews()
    }
    
    func setupViews() {
        let normalColor: UIColor = #colorLiteral(red: 0.1129845455, green: 0.4494044185, blue: 0.747171104, alpha: 1)
        let textColor: UIColor = #colorLiteral(red: 0.2969530523, green: 0.2969608307, blue: 0.2969566584, alpha: 1)
//        dateTf.attributedPlaceholder = NSAttributedString(string: "00:00",
//        attributes: [NSAttributedString.Key.foregroundColor: textColor])
        
    }
    
    func setupUI() {
        let prevImg = UIImage(named: "ic_left")
        let tintedPrevImage = prevImg?.withRenderingMode(.alwaysTemplate)
        prevBtn.setImage(tintedPrevImage, for: .normal)
        prevBtn.tintColor = #colorLiteral(red: 0.1129845455, green: 0.4494044185, blue: 0.747171104, alpha: 1)
        
        let nextImg = UIImage(named: "ic_right")
        let tintedNextImage = nextImg?.withRenderingMode(.alwaysTemplate)
        nextBtn.setImage(tintedNextImage, for: .normal)
        nextBtn.tintColor = #colorLiteral(red: 0.1129845455, green: 0.4494044185, blue: 0.747171104, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateDate()
    }
    
    func searchData() {
        self.filteredSheetList.removeAll()
        
//        let template = TimeLog()
//        template.userId = -1
//        self.filteredSheetList.append(template)
        let formatter = DateFormatter()
         formatter.dateFormat = "yyyy-MM-dd"
        self.loadData(date: formatter.string(from: datePicker.date))
//        self.filteredSheetList.append(contentsOf: self.sheetList.filter{ $0.filtered(time: dateTf.text!) })
        
//        self.tableView.reloadData()
    }
    
    func reloadDataAndUI() {
        var sum = "00:00"
        self.filteredSheetList.map {
            sum = DateTimeUtils.share.sumServerTime(sum: sum, time: $0.hours)
        }
        self.sumLb.text = sum
        self.tableView.reloadData()
    }
    
    func loadData(date: String) {
        
        let myUser = User.readUserFromArchive()
        if (myUser != nil && myUser?.count != 0){
            let user = myUser![0]
            
            APIHandler.sharedInstance.getTimeSheets(userId: user.userId, date: date) { (isSuccess, response) in
                   if isSuccess {
                       let success = response!["success"] as? Bool ?? false
                       if success{
                            let resultObject = response!["result"] as? NSArray
                        if resultObject != nil {
                            let arrObjs = resultObject!
//                            if arrObjs != nil {
                                for i in 0 ..< arrObjs.count {
                                    let dict = arrObjs.object(at: i) as! NSDictionary
                                    let log = TimeLog()
                                    log.timesheetId = dict["timesheetId"] as? Int
                                    log.userId = dict["userId"] as? Int
                                    log.taskId = dict["taskId"] as? Int
                                    log.taskName = dict["taskName"] as? String
                                    log.projectId = dict["projectId"] as? Int
                                    log.projectName = dict["projectName"] as? String
                                    log.spentAt = dict["spentAt"] as? String
                                    log.startAt = dict["startedAt"] as? String
                                    log.endAt = dict["endedAt"] as? String
                                    log.hours = dict["hours"] as? Double
                                    log.comment = dict["notes"] as? String
                                    
//                                    log.creationTime = DateTimeUtils.share.ServerToLocalDate(date: dict["creationTime"] as? String)
                                    self.filteredSheetList.append(log)
//                                }
                            }
                            self.reloadDataAndUI()
//                            self.loadExtraData(userId: user.userId)
                        }
                            
                       }else{
                           AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
                       }
                   }else{
                      AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
                   }
               }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredSheetList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "loggerList", for: indexPath) as! LoggerListTableViewCell
        
        
            
        let log = self.filteredSheetList[indexPath.row]
        if log.userId == -1 {
            cell.projectLb.text = "Project"
            cell.taskLb.text = "Task"
            cell.startLb.text = "Start"
            cell.endLb.text = "End"
            cell.hoursLb.text = "Hours"
        } else {
            cell.projectLb.text = log.projectName ?? " "
            cell.taskLb.text = log.taskName ?? " "
            cell.startLb.text = log.startAt ?? ""
            cell.endLb.text = log.endAt ?? ""
//            cell.hoursLb.text = String(log.hours ?? 0.0)
            cell.hoursLb.text = DateTimeUtils.share.getLocalTimeFromServer(time: log.hours)
            cell.commentLb.text = String(log.comment ?? " ")
        }
        
        cell.delegate = self
        cell.indexPath = indexPath
        
        return cell
    }
    
    func onEditBtnTapped(at index: IndexPath) {
        selectedLog = self.filteredSheetList[index.row]
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC") as? TimeRegistrationController
        {
            vc.selectedLog = self.filteredSheetList[index.row]
            present(vc, animated: true, completion: nil)
        }
        
    }
    
    func showDatePicker(){
           //Formate Date
           datePicker.datePickerMode = .date
           
           //ToolBar
           let toolbar = UIToolbar()
           toolbar.sizeToFit()
           let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
           let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
           let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
           
           toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
           
           dateTf.inputAccessoryView = toolbar
           dateTf.inputView = datePicker
           
       }
    
    @objc func donedatePicker(){
           updateDate()
           self.view.endEditing(true)
       }
       
    @IBAction func onPrev(_ sender: Any) {
        datePicker.date = datePicker.date.dayBefore
        updateDate()
    }
    
    @IBAction func onNext(_ sender: Any) {
        datePicker.date = datePicker.date.dayAfter
        updateDate()
    }
    
       func updateDate() {
           let formatter = DateFormatter()
           formatter.dateFormat = "dd-MM-yyyy"
           dateTf.text = formatter.string(from: datePicker.date)
            searchData()
       }
       
       @objc func cancelDatePicker(){
           self.view.endEditing(true)
       }
    
    @IBAction func onClickBack(_ sender: Any) {
        selectedLog = nil
        performSegue(withIdentifier: "gotoHome", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is TimeRegistrationController {
            let vc = segue.destination as! TimeRegistrationController
            vc.selectedLog = self.selectedLog
        }
    }

    //    func loadExtraData(userId: String) {
    //        APIHandler.sharedInstance.getExtraTimeSheets(userId: userId) { (isSuccess, response) in
    //               if isSuccess {
    //                   let success = response!["success"] as! Bool
    //                   if success{
    //                        let resultObject = response!["result"] as! NSDictionary
    //                        let arrObjs = resultObject["items"] as! NSArray
    //                    if arrObjs.count == self.sheetList.count {
    //                        for i in 0 ..< arrObjs.count {
    //                            let dict = arrObjs.object(at: i) as! NSDictionary
    //                            self.sheetList[i].projectName = dict["projectName"] as? String
    //                            self.sheetList[i].taskName = dict["taskName"] as? String
    //                        }
    //                    }
    //
    //                    self.searchData()
    //                   }else{
    //                       AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
    //                   }
    //               }else{
    //                  AppUtility?.displayAlert(title: NSLocalizedString("alert_app_name", comment: ""), messageText: NSLocalizedString("error_400", comment: ""), delegate: self)
    //               }
    //           }
    //    }
    
}
