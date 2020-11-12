//
//  ActivityViewController.swift
//  PORTLR
//
//  Created by Hunain on 21/05/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit
import KYDrawerController
import CallKit
import Contacts

class ActivityViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, ActivityListDelegate {

    let datePicker = UIDatePicker()
    
    //MARK: Outlets
    @IBOutlet weak var tblCallList: UITableView!
    @IBOutlet weak var tfDate: UITextField!
    
    var myCall: [Call]? {didSet {}}
    var indexCall = 0
    var arrCalls = [Call]()
    var indexCallerName = 0
    
    //MARK:- View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        registerCallDataManually()
        
        self.setupView()
        self.showDatePicker()
    }
    
    func registerCallDataManually() {
        let cal = Call()
        let callID = "\(AppUtility!.getCurrentMillis())"
        cal.callId = callID
        
        cal.status = "incoming"
        cal.callDate = "05/07/2020"
        let callStart = "05/06/2020 10:00:00"
        cal.callStartTime = callStart
        let formaterEndTime = DateFormatter()
        formaterEndTime.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let callEnd = formaterEndTime.string(from: Date())
        cal.callEndTime = callEnd
        let dateStart = formaterEndTime.date(from: callStart)
        let dateEnd = formaterEndTime.date(from: callEnd)
        cal.duration = AppUtility!.offsetFrom(dateFrom: dateStart!, dateTo: dateEnd!)
        print(Date())
        
        var mCall = Call.readCallFromArchive()
        if (mCall != nil && mCall!.count != 0){
            mCall!.append(cal)
        }else{
            mCall = [cal]
        }
        if Call.saveCallToArchive(call: mCall!){
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        if let value = UserDefaults.standard.string(forKey:strDate) {
//            print(value)
//            self.tfDate.text = value
//        }else{
//            let formaterDate = DateFormatter()
//            formaterDate.dateFormat = "dd-MM-yyyy"
//            self.tfDate.text = formaterDate.string(from: Date())
//            AppUtility?.saveObject(obj: self.tfDate.text!, forKey: strDate)
//        }
        
        updateDate()
    }
    
    //MARK:- Setup View
    func setupView() {
        self.tblCallList.rowHeight = 100
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.pickedDate), name:NSNotification.Name("PickedDate") , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchLatestData), name:NSNotification.Name("AppActive") , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setCompanyData), name:NSNotification.Name("CompanyData") , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setCallStatus), name:NSNotification.Name("CallStatus") , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setCallerName), name:NSNotification.Name("CallerName") , object: nil)
    }
    
    //MARK:- Utility Methods
    
    @objc func pickedDate(notify:Notification){
        let strDate = notify.object as! String
        self.tfDate.text = strDate
        self.searchCallsWithDate()
    }
    
    @objc func fetchLatestData(notify:Notification){
        if let value = UserDefaults.standard.string(forKey:strDate) {
            self.tfDate.text = value
        }else{
            let formaterDate = DateFormatter()
            formaterDate.dateFormat = "dd-MM-yyyy"
            self.tfDate.text = formaterDate.string(from: Date())
            AppUtility?.saveObject(obj: self.tfDate.text!, forKey: strDate)
        }
        self.searchCallsWithDate()
        
    }
    
    @objc func setCompanyData(notify:Notification){
        let data = notify.object as! [String]
        let cal = self.arrCalls[self.indexCall]
        cal.companyName = data[1]
        cal.companyId = data[0]
        let callID = data[2]
        self.tblCallList.reloadData()
        
        self.myCall = Call.readCallFromArchive()
        for obj in self.myCall!{
            if obj.callId == callID{
                obj.companyName = data[1]
                obj.companyId = data[0]
                if Call.saveCallToArchive(call: self.myCall!){
                    self.myCall = Call.readCallFromArchive()
                }
                break
            }
        }
        if Call.saveCallToArchive(call: self.myCall!){
            
        }
    }
    
    @objc func setCallStatus(notify:Notification){
        let callID = notify.object as! String
        let cal = self.arrCalls[self.indexCall]
        cal.clientStatus = "1"
        self.tblCallList.reloadData()
        
        self.myCall = Call.readCallFromArchive()
        for obj in self.myCall!{
            if obj.callId == callID{
                obj.clientStatus = "1"
                if Call.saveCallToArchive(call: self.myCall!){
                    self.myCall = Call.readCallFromArchive()
                }
                break
            }
        }
    }
    
    @objc func setCallerName(notify:Notification){
        let callerName = notify.object as! String
        let cal = self.arrCalls[self.indexCallerName]
        cal.callerName = callerName
        let callID = cal.callId
        self.tblCallList.reloadData()
        
        self.myCall = Call.readCallFromArchive()
        for obj in self.myCall!{
            if obj.callId == callID{
                obj.callerName = callerName
                if Call.saveCallToArchive(call: self.myCall!){
                    self.myCall = Call.readCallFromArchive()
                }
                break
            }
        }
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
    
    func searchCallsWithDate(){
//        if let value = UserDefaults.standard.string(forKey:strDate) {
//
//        }
        
        self.myCall = Call.readCallFromArchive()
        self.arrCalls.removeAll()
        if (self.myCall != nil && self.myCall?.count != 0){
            for obj in self.myCall!{
                //let obj = self.arrCalls[i]
                let dateCall = self.changeDateFormat(strDate: obj.callDate, format: "dd-MM-yyyy")
                if dateCall == tfDate.text! && obj.isDelete != true && obj.projectId == nil {
                    self.arrCalls.append(obj)
                }
            }
            self.tblCallList.reloadData()
        }
        
    }
    
    func showActionSheet(index:Int){
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionPhoneBook = UIAlertAction(title: "Select from Phonebook", style: .default) { (ac:UIAlertAction) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactsVC") as! ContactsViewController
            self.indexCallerName = index
            self.present(vc, animated: true, completion: nil)
        }
        let actionunknown = UIAlertAction(title: "Unknown Number", style: .default) { (ac:UIAlertAction) in
            let cal = self.arrCalls[index]
            cal.callerName = "Unknown"
            let callID = cal.callId
            self.tblCallList.reloadData()
            
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
    
    func showContactList(index:Int){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactsVC") as! ContactsViewController
        self.indexCallerName = index
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK:- Button Action
//    @IBAction func btnMenuAction(_ sender: Any) {
//        if let drawerController = self.parent as? KYDrawerController {
//            drawerController.setDrawerState(.opened, animated: true)
//        }
//    }
    

    
    //MARK: API Methods
    
    //MARK:- DELEGATE METHODS
    
    //MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //self.myCall = Call.readCallFromArchive()
        /*if (self.myCall != nil && self.myCall!.count != 0){
            return self.myCall!.count
        }else{
            return 0
        }*/
        return self.arrCalls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellList", for: indexPath) as! CallListTableViewCell
        
        let cal = self.arrCalls[indexPath.row]
//        cell.lblDate.text = self.changeDateFormat(strDate: cal.callDate, format: "dd-MM-yyyy")
        
//        if cal.status == "disconnected"{
//            cell.btnDuration.setImage(nil, for: .normal)
//            cell.btnDuration.setTitle(cal.duration, for: .normal)
//        }else{
//            cell.btnDuration.setTitle(cal.duration, for: .normal)
//            if cal.status == "outgoing"{
//                cell.btnDuration.setImage(UIImage(named: "OutGoingCall"), for: .normal)
//            }
//            if cal.status == "incoming"{
//                cell.btnDuration.setImage(UIImage(named: "IncomingCall"), for: .normal)
//            }
//        }
//        if cal.clientStatus == "1"{
//           cell.btnStatus.setImage(UIImage(named: "StatusActive"), for: .normal)
//        }else{
//            cell.btnStatus.setImage(UIImage(named: "Status"), for: .normal)
//        }
        
        cell.btnDuration.setTitle(cal.duration, for: .normal)
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let dateStart = dateFormat.date(from: cal.callStartTime)
        let dateEnd = dateFormat.date(from: cal.callEndTime)
        dateFormat.dateFormat = "HH:mm:ss"
        let strStartCall = dateFormat.string(from: dateStart!)
        let strEndCall = dateFormat.string(from: dateEnd!)
        cell.lblCallerName.text = "\(strStartCall) - \(strEndCall)"
        
        cell.delegate = self
        cell.indexPath = indexPath
        
        return cell
    }
    
    func onEditBtnTap(at index: IndexPath!) {
        let selCall = self.arrCalls[index.row]
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC") as? TimeRegistrationController
        {
            vc.selectedCall = selCall
            present(vc, animated: true, completion: nil)
        }
    }
    
    func onDeleteBtnTap(at index: IndexPath!) {
        let selCall = self.arrCalls[index.row]
        
        let refreshAlert = UIAlertController(title: "Are you sure?", message: "", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            selCall.isDelete = true
            Call.saveCall(call: selCall)
            self.updateDate()
        }))

        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
              
        }))

        present(refreshAlert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.indexCall = indexPath.row
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
//        let cal = self.arrCalls[indexPath.row]
//        vc.objCall = cal
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
    
    //MARK:- View Life Cycle End here...
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func btnCalanderAction(_ sender: Any) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CalanderVC") as! CalanderViewController
//        self.present(vc, animated: true, completion: nil)
//    }
    
    @IBAction func onPrev(_ sender: Any) {
        datePicker.date = datePicker.date.dayBefore
        updateDate()
    }
    
    @IBAction func onNext(_ sender: Any) {
        datePicker.date = datePicker.date.dayAfter
        updateDate()
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
        
        tfDate.inputAccessoryView = toolbar
        tfDate.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
              updateDate()
              self.view.endEditing(true)
          }
    
    @objc func cancelDatePicker(){
              self.view.endEditing(true)
          }
    
    func updateDate() {
              let formatter = DateFormatter()
              formatter.dateFormat = "dd-MM-yyyy"
              tfDate.text = formatter.string(from: datePicker.date)

        self.searchCallsWithDate()
        
          }
}
