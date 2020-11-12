//
//  Utility.swift
//  SuperMarket
//
//  Created by macbook on 10/31/16.
//  Copyright © 2016 MCIT. All rights reserved.
//

import UIKit
import SVProgressHUD
//import FBSDKCoreKit
//import FBSDKLoginKit
//import Foundation

protocol DatePickerDelegate {
    func timePicked(time: String)
}

//import Reachability

let AppUtility =  Utility.sharedUtility()
let ud = UserDefaults.standard

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

//MARK:- Server URL Definition
let imageDownloadUrl  = ""

//MARK:- User Defaults Keys
let strToken = "strToken"
let strDate = "strDate"
let strURL = "strURL"

let delegate:AppDelegate = UIApplication.shared.delegate as!  AppDelegate



//MARK:- Utility Initialization Methods
class Utility: NSObject {
    
    //var fbLogin:FBSDKLoginManager!
    var datePickerDelegate : DatePickerDelegate?
    class func sharedUtility()->Utility!
    {
        struct Static
        {
            static var sharedInstance:Utility?=nil;
            static var onceToken = 0
        }
        Static.sharedInstance = self.init();
        return Static.sharedInstance!
    }
    required override init() {
    }
    
//MARK:- Get Date Method
    func getDateFromUnixTime(_ unixTime:String) -> String {
        let date = Date(timeIntervalSince1970: Double(unixTime)!)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let currentTime =  formatter.string(from: date as Date)
        return currentTime;
    }
    
    func getAgeYears(birthday:String)-> Int{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let birthdate = formatter.date(from: birthday)
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthdate!, to: now)
        let age = ageComponents.year!
        return age
    }
    
    func showDatePicker(fromVC : UIViewController){
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 250)
        let pickerView = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        pickerView.datePickerMode = .date
        //pickerView.locale = NSLocale(localeIdentifier: "\(Formatter.getInstance.getAppTimeFormat().rawValue)") as Locale
        vc.view.addSubview(pickerView)
        
        let alertCont = UIAlertController(title: "Choose Date", message: "", preferredStyle: UIAlertController.Style.alert)
        
        alertCont.setValue(vc, forKey: "contentViewController")
        let setAction = UIAlertAction(title: "Select", style: .default) { (action) in
            if self.datePickerDelegate != nil{
                //let selectedTime = Formatter.getInstance.convertDateToTime(date: pickerView.date)
                //self.datePickerDelegate!.timePicked(time: selectedTime)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy"
                formatter.timeZone = TimeZone.current
                let selectedTime = formatter.string(from: pickerView.date)
                self.datePickerDelegate!.timePicked(time: selectedTime)
            }
        }
        alertCont.addAction(setAction)
        alertCont.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        fromVC.present(alertCont, animated: true)
    }
    
//MARK: Check Internet
    func connected() -> Bool
    {
        let reachibility = Reachability.forInternetConnection()
        let networkStatus = reachibility?.currentReachabilityStatus()
        
        return networkStatus != NotReachable
        
    }
    
//MARK:- Validation Text
    func hasValidText(_ text:String?) -> Bool
    {
        if let data = text
        {
            let str = data.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if str.count>0
            {
                return true
            }
            else
            {
                return false
            }
        }
        else
        {
            return false
        }
        
    }
    
  //MARK:- Validation Atleast 1 special schracter or number
    
    func checkTextHaveChracterOrNumber( text : String) -> Bool{
        
        
//        let text = text
//        let capitalLetterRegEx  = ".*[A-Z]+.*"
//        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
//        let capitalresult = texttest.evaluate(with: text)
//        print("\(capitalresult)")
        
        
        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = texttest1.evaluate(with: text)
        print("\(numberresult)")
        
        
        let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
        let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        
        let specialresult = texttest2.evaluate(with: text)
        print("\(specialresult)")
        
        //return capitalresult || numberresult || specialresult
        return numberresult || specialresult
        
    }
    
//MARK:- Validation Email
    func isEmail(_ email:String  ) -> Bool
    {
        let strEmailMatchstring = "\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"
        let regExPredicate = NSPredicate(format: "SELF MATCHES %@", strEmailMatchstring)
        if(!isEmpty(email as String?) && regExPredicate.evaluate(with: email))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
//MARK:- Validation Empty
    func isEmpty(_ thing : String? )->Bool {
        
        if (thing?.count == 0) {
            return true
        }
//        if(thing as? Data == nil)
//        {
//            return false;
//        }
//        else if(thing!.contains(NSNull.self))
//        {
//            return false
//        }
//        else if((thing as! Data).count == 0)
//        {
//            return false
//        }
//        else if((thing! as! NSArray).count == 0)
//        {
//            return false
//        }
        return false;
    }

    
//MARK:- Show Alert
    func displayAlert(title titleTxt:String, messageText msg:String, delegate controller:UIViewController) ->()
    {
            let alertController = UIAlertController(title: titleTxt, message: msg, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                controller.present(alertController, animated: true, completion: nil)

    }
    
    //MARK:- Color with HEXA
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //MARK:- Get & Set Methods For UserDefaults
    
    func saveObject(obj:String,forKey strKey:String){
        ud.set(obj, forKey: strKey)
    }
    
    func getObject(forKey strKey:String) -> String {
        if let obj = ud.value(forKey: strKey) as? String{
            let obj2 = ud.value(forKey: strKey) as! String
            return obj2
        }else{
            return ""
        }
    }
    
    func deleteObject(forKey strKey:String) {
        ud.set(nil, forKey: strKey)
    }
    
    //MARK:- SV Hud Methods
    
    func showHud(){
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)//gradient
        SVProgressHUD.show(withStatus: nil)
    }
    
    func hideHud(){
        SVProgressHUD.dismiss()
    }
    
    //MARK: Add Delay
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    //MARK: Calculate Time
    
    func timeAgoSinceDate(_ date:Date,currentDate:Date, numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = currentDate
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
        
    }
    
    func calculateTimeDifference(start: String) -> String {
        let formatter = DateFormatter()
        //        2018-12-17 18:01:34
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var startString = "\(start)"
        if startString.count < 4 {
            for _ in 0..<(4 - startString.count) {
                startString = "0" + startString
            }
        }
        let currentDateTime = Date()
        let strcurrentDateTime = formatter.string(from: currentDateTime)
        var endString = "\(strcurrentDateTime)"
        if endString.count < 4 {
            for _ in 0..<(4 - endString.count) {
                endString = "0" + endString
            }
        }
        let startDate = formatter.date(from: startString)!
        let endDate = formatter.date(from: endString)!
        let difference = endDate.timeIntervalSince(startDate)
        if (difference / 3600) > 24{
            let differenceInDays = Int(difference/(60 * 60 * 24 ))
            return "\(differenceInDays) DAY AGO"
        }else{
            return "\(Int(difference) / 3600)HOURS \(Int(difference) % 3600 / 60)MIN AGO"
        }
    }
    
    func offsetFrom(dateFrom : Date,dateTo:Date) -> String {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: dateFrom, to: dateTo);
        
//        let seconds = "\(difference.second ?? 0)"
//        let minutes = "\(difference.minute ?? 0)" + ":" + seconds
//        let hours = "\(difference.hour ?? 0)" + ":" + minutes
//        let days = "\(difference.day ?? 0)d" + ":" + hours
        
//        if let day = difference.day, day          > 0 { return days }
//        if let hour = difference.hour, hour       > 0 { return hours }
//        if let minute = difference.minute, minute > 0 { return minutes }
//        if let second = difference.second, second > 0 { return seconds }
//        return ""
        
        var seconds = "00"
        var minutes = "00"
        var hours = "00"
        
        if difference.second != nil {
            seconds = "\(difference.second!)"
            if seconds.count == 1 {
                seconds = "0\(seconds)"
            }
        }
        
        if difference.minute != nil {
            minutes = "\(difference.minute!)"
            if minutes.count == 1 {
                minutes = "0\(minutes)"
            }
        }
        
        if difference.hour != nil {
            hours = "\(difference.hour!)"
            if hours.count == 1 {
                hours = "0\(hours)"
            }
        }
        
        return "\(hours)" + ":" + "\(minutes)" + ":" + "\(seconds)"
        
    }
    
    //MARK: Random Number
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    //MARK: Send Notification
    /*func sendPushNotification(body: [String : Any]) {
        print("push body",body)
        //let paramString  = ["to" : token, "notification" : ["title" : "Group Tag", "body" : "You recieved cake"]/*, "data" : ["user" : self.myUser![0].email]*/] as [String : Any]
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        let json = try! JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
        let outString = String(data:json, encoding:.utf8)
        
        print("outstring",outString!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AIzaSyBhZyP653nt4vu3insFqTK7I0c5RAk4voM", forHTTPHeaderField: "Authorization")
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = json
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            do {
                print("task",response!)
                if let jsonData = data {
                    let outString = String(data:jsonData, encoding:.utf8)
                    print("out",outString!)
                    if let jsonDataDict = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }*/
}
