//
//  AppDelegate.swift
//  PORTLR
//
//  Created by Hunain on 21/05/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import CallKit
import AVFoundation
import BackgroundTasks
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var callObserver: CXCallObserver!
    var myCall: [Call]? {didSet {}}
    var callStatus = ""
    var callEnd = ""
    var callStart = ""
    var callDate = ""
    var callPreviousStatus = ""
    var myUser:[User]?{didSet{}}
    var player: AVAudioPlayer?
    
    var locationManager:CLLocationManager!
    
    var isFirstTimeBackground = true
    var isRunningLocationDetect = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldPlayInputClicks = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        
    
        
        callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil)
        self.myUser = User.readUserFromArchive()
        
        
        registerLocalNotification()
        UNUserNotificationCenter.current().delegate = self
        
        
        detectLocation()
        
        return true
    }
    
    func detectLocation() {
        
        locationManager = CLLocationManager()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        
        if CLLocationManager.locationServicesEnabled(){
            isRunningLocationDetect = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopDetectLocation() {
        
        if UIApplication.shared.applicationState == .background {
            isRunningLocationDetect = false
            locationManager.stopUpdatingLocation()
        }
    }
    
    func startDetectLocation() {
        
        print("startDetectLocation")
        
        if isRunningLocationDetect {
            print("1")
            return
        }
        
        let autoTime = AutoTimeTrack()
        autoTime.loadObj()
        
        if !autoTime.isCallLogger && !autoTime.isLocation {
            print("2")
            return
        }
        
        if autoTime.workLocation.isEmpty {
            print("3")
            return
        }
        
        if DateTimeUtils.share.timeCompare(time1: autoTime.startTime, time2: Date()) {
            print("4")
            return
        }
        
        if DateTimeUtils.share.timeCompare(time1: Date(), time2: autoTime.endTime) {
            print("5")
            return
        }
        
        let wday = autoTime.getWeekday()
        print(wday)
        
        var weekday = 1
        if wday == 1 {
            weekday = 6
        } else {
            weekday = wday - 2
        }
        
        if !autoTime.workdays[weekday] {
            return
        }
        
        if CLLocationManager.locationServicesEnabled(){
            isRunningLocationDetect = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let userLocation :CLLocation = locations[0] as CLLocation

        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        CurrentLocationManager.lat = userLocation.coordinate.latitude
        CurrentLocationManager.lng = userLocation.coordinate.longitude
        
        let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
                    if (error != nil){
                        print("error in reverseGeocode")
                    }
                    let placemark = placemarks
                    if placemark != nil && placemark!.count>0{
                        let placemark = placemarks![0]
//                        print(placemark.locality!)
//                        print(placemark.administrativeArea!)
//                        print(placemark.country!)

                        CurrentLocationManager.address = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
                    }
                }

        let autoTime = AutoTimeTrack()
        autoTime.loadObj()
        
        if !autoTime.isCallLogger && !autoTime.isLocation {
            stopDetectLocation()
            return
        }
        
        if autoTime.workLocation.isEmpty {
            stopDetectLocation()
            return
        }
        
        if DateTimeUtils.share.timeCompare(time1: autoTime.startTime, time2: Date()) {
            stopDetectLocation()
            return
        }
        
        if DateTimeUtils.share.timeCompare(time1: Date(), time2: autoTime.endTime) {
            stopDetectLocation()
            return
        }
        
        let wday = autoTime.getWeekday()
//        print(wday)
        
        var weekday = 1
        if wday == 1 {
            weekday = 6
        } else {
            weekday = wday - 2
        }
        
        if !autoTime.workdays[weekday] {
            stopDetectLocation()
            return
        }
        
        if autoTime.notificationTriggered {
            return
        }
        
        print(autoTime.lat)
        print(autoTime.lng)
        
        let currentCoordinate = CLLocation(latitude: autoTime.lat, longitude: autoTime.lng)
        let updatedCoordinate = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let distanceInMeters = currentCoordinate.distance(from: updatedCoordinate)
        print("distance: \(distanceInMeters)")
        if distanceInMeters < 100 {
            return
        }
        
        autoTime.notificationTriggered = true
        autoTime.saveObj()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let cusTime = formatter.string(from: Date())
        
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "You have left your location \(cusTime), Check-out?"
        notificationContent.body = ""

        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)

        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "location-update", content: notificationContent, trigger: notificationTrigger)

        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
//            print("Notification display")
        }
            
        }
    
        func applicationDidEnterBackground(_ application: UIApplication) {
            // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
            // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
            let formaterDate = DateFormatter()
            formaterDate.dateFormat = "dd-MM-yyyy"
            let strDT = formaterDate.string(from: Date())
            AppUtility?.saveObject(obj: strDT, forKey: strDate)
            
            startDetectLocation()
            
//            scheduleLocalNotification()
            
    //        scheduleImageFetcher()
            
            /*Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
                print("time")
            }*/
//            if isFirstTimeBackground {
//                isFirstTimeBackground = false
//                detectLocation()
//            }
            
//            UIApplication.shared.beginBackgroundTask(withName: "call") {
//                self.callObserver.setDelegate(self, queue: nil)
//            }
            
            //self.playSound()
            /*let options = AVAudioSession.CategoryOptions.mixWithOthers
            let mode = AVAudioSession.Mode.default
            let category = AVAudioSession.Category.playback
            try? AVAudioSession.sharedInstance().setCategory(category, mode: mode, options: options)
            //---------------------------------------------------------------------------------
            try? AVAudioSession.sharedInstance().setActive(true)*/
            
            
        }
    
//    @objc func notificationReceived() {
//        print(Date())
//    }
    
     @available(iOS 13.0, *)
    func handleImageFetcherTask(task: BGProcessingTask) {
        scheduleImageFetcher() // Recall

        task.expirationHandler = {
        }

        print("recall")
        scheduleLocalNotification()
        task.setTaskCompleted(success: true)

    }
    
    func scheduleImageFetcher() {
        if #available(iOS 13.0, *) {
            let request = BGProcessingTaskRequest(identifier: "com.SO.imagefetcher")
            request.requiresNetworkConnectivity = false // Need to true if your task need to network process. Defaults to false.
            request.requiresExternalPower = false

            request.earliestBeginDate = Date(timeIntervalSinceNow: 20) // Featch Image Count after 1 minute.
            //Note :: EarliestBeginDate should not be set to too far into the future.
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("Could not schedule image featch: \(error)")
            }
        } else {
            // Fallback on earlier versions
        }

    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

//        UIApplication.shared.beginBackgroundTask(withName: "call") {
//           self.callObserver.setDelegate(self, queue: nil)
//        }
        //self.playSound()
        //self.doBackgroundTask()
    }



    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        NotificationCenter.default.post(name: NSNotification.Name("AppActive"), object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//        UIApplication.shared.beginBackgroundTask(withName: "call") {
//            self.callObserver.setDelegate(self, queue: nil)
//        }
    }
    
    func playSound() {
        /*guard let url = Bundle.main.url(forResource: "1", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            player.numberOfLoops = -1
            //player.volume = 0.0
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }*/
        let options = AVAudioSession.CategoryOptions.mixWithOthers
        let mode = AVAudioSession.Mode.default
        let category = AVAudioSession.Category.playback
        try? AVAudioSession.sharedInstance().setCategory(category, mode: mode, options: options)
        //---------------------------------------------------------------------------------
        try? AVAudioSession.sharedInstance().setActive(true)
        let path = Bundle.main.path(forResource: "1.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            self.player!.numberOfLoops = -1
            self.player!.volume = 0.0
            self.player!.play()
        } catch {
            // couldn't load file :(
        }
        
    }
    
}

extension AppDelegate: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        //Change format to dd-MM-yyyy
        self.myUser = User.readUserFromArchive()
        if (self.myUser != nil && self.myUser?.count != 0){
        if UIApplication.shared.applicationState == .background{
          print("background")
            if call.hasEnded == true {
                print("Disconnected")
                print(call.uuid)
                let cal = Call()
                let callID = "\(AppUtility!.getCurrentMillis())"
                cal.callId = callID
                if self.callStatus == "dialing"{
                    /*cal.callDate = self.callDate
                     cal.callStartTime = self.callStart
                     cal.callEndTime = self.callStart
                     cal.status = "disconnected"
                     cal.duration = "0s"*/
                    return
                }
                if self.callStatus == "incoming"{
                    /*cal.callDate = self.callDate
                     cal.callStartTime = self.callStart
                     cal.callEndTime = self.callStart
                     cal.status = "disconnected"
                     cal.duration = "0s"*/
                    return
                }
                if self.callStatus == "connected"{
                    if self.callPreviousStatus == "dialing"{
                        cal.status = "outgoing"
                        cal.callDate = self.callDate
                        cal.callStartTime = self.callStart
                        let formaterEndTime = DateFormatter()
                        formaterEndTime.dateFormat = "MM/dd/yyyy HH:mm:ss"
                        self.callEnd = formaterEndTime.string(from: Date())
                        cal.callEndTime = self.callEnd
                        let dateStart = formaterEndTime.date(from: self.callStart)
                        let dateEnd = formaterEndTime.date(from: self.callEnd)
                        cal.duration = AppUtility!.offsetFrom(dateFrom: dateStart!, dateTo: dateEnd!)
                    }
                    if self.callPreviousStatus == "incoming"{
                        cal.status = "incoming"
                        cal.callDate = self.callDate
                        cal.callStartTime = self.callStart
                        let formaterEndTime = DateFormatter()
                        formaterEndTime.dateFormat = "MM/dd/yyyy HH:mm:ss"
                        self.callEnd = formaterEndTime.string(from: Date())
                        cal.callEndTime = self.callEnd
                        let dateStart = formaterEndTime.date(from: self.callStart)
                        let dateEnd = formaterEndTime.date(from: self.callEnd)
                        cal.duration = AppUtility!.offsetFrom(dateFrom: dateStart!, dateTo: dateEnd!)
                        print(Date())
                    }
                    self.myCall = Call.readCallFromArchive()
                    if (self.myCall != nil && self.myCall!.count != 0){
                        self.myCall!.append(cal)
                    }else{
                        self.myCall = [cal]
                    }
                    if Call.saveCallToArchive(call: self.myCall!){
                        self.callStatus = ""
                        self.callEnd = ""
                        self.callStart = ""
                        self.callDate = ""
                        self.callPreviousStatus = ""
                    }
                }
            }
            if call.isOutgoing == true && call.hasConnected == false {
                print("Dialing")
                print(call.uuid)
                self.callStatus = "dialing"
                let formaterDate = DateFormatter()
                let formaterStartTime = DateFormatter()
                formaterDate.dateFormat = "MM/dd/yyyy"
                formaterStartTime.dateFormat = "MM/dd/yyyy HH:mm:ss"
                self.callDate = formaterDate.string(from: Date())
                self.callStart = formaterStartTime.string(from: Date())
                print(Date())
            }
            if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
                print("Incoming")
                print(call.uuid)
                self.callStatus = "incoming"
                let formaterDate = DateFormatter()
                let formaterStartTime = DateFormatter()
                formaterDate.dateFormat = "MM/dd/yyyy"
                formaterStartTime.dateFormat = "MM/dd/yyyy HH:mm:ss"
                self.callDate = formaterDate.string(from: Date())
                self.callStart = formaterStartTime.string(from: Date())
                print(Date())
            }
            if call.hasConnected == true && call.hasEnded == false {
                print("Connected")
                print(call.uuid)
                self.callPreviousStatus = self.callStatus
                self.callStatus = "connected"
                let formaterDate = DateFormatter()
                let formaterStartTime = DateFormatter()
                formaterDate.dateFormat = "MM/dd/yyyy"
                formaterStartTime.dateFormat = "MM/dd/yyyy HH:mm:ss"
                self.callDate = formaterDate.string(from: Date())
                self.callStart = formaterStartTime.string(from: Date())
                print(Date())
            }
            
            }else{
            print("active")
            print("inactive")
            
            if call.hasEnded == true {
                print("Disconnected")
                print(call.uuid)
                let cal = Call()
                let callID = "\(AppUtility!.getCurrentMillis())"
                cal.callId = callID
                if self.callStatus == "dialing"{
                    /*cal.callDate = self.callDate
                    cal.callStartTime = self.callStart
                    cal.callEndTime = self.callStart
                    cal.status = "disconnected"
                    cal.duration = "0s"*/
                    return
                }
                if self.callStatus == "incoming"{
                    /*cal.callDate = self.callDate
                    cal.callStartTime = self.callStart
                    cal.callEndTime = self.callStart
                    cal.status = "disconnected"
                    cal.duration = "0s"*/
                    return
                }
                if self.callStatus == "connected"{
                    if self.callPreviousStatus == "dialing"{
                        cal.status = "outgoing"
                        cal.callDate = self.callDate
                        cal.callStartTime = self.callStart
                        let formaterEndTime = DateFormatter()
                        formaterEndTime.dateFormat = "MM/dd/yyyy HH:mm:ss"
                        self.callEnd = formaterEndTime.string(from: Date())
                        cal.callEndTime = self.callEnd
                        let dateStart = formaterEndTime.date(from: self.callStart)
                        let dateEnd = formaterEndTime.date(from: self.callEnd)
                        cal.duration = AppUtility!.offsetFrom(dateFrom: dateStart!, dateTo: dateEnd!)
                    }
                    if self.callPreviousStatus == "incoming"{
                        cal.status = "incoming"
                        cal.callDate = self.callDate
                        cal.callStartTime = self.callStart
                        let formaterEndTime = DateFormatter()
                        formaterEndTime.dateFormat = "MM/dd/yyyy HH:mm:ss"
                        self.callEnd = formaterEndTime.string(from: Date())
                        cal.callEndTime = self.callEnd
                        let dateStart = formaterEndTime.date(from: self.callStart)
                        let dateEnd = formaterEndTime.date(from: self.callEnd)
                        cal.duration = AppUtility!.offsetFrom(dateFrom: dateStart!, dateTo: dateEnd!)
                        print(Date())
                    }
                    self.myCall = Call.readCallFromArchive()
                    if (self.myCall != nil && self.myCall!.count != 0){
                        self.myCall!.append(cal)
                    }else{
                        self.myCall = [cal]
                    }
                    if Call.saveCallToArchive(call: self.myCall!){
                        self.callStatus = ""
                        self.callEnd = ""
                        self.callStart = ""
                        self.callDate = ""
                        self.callPreviousStatus = ""
                        NotificationCenter.default.post(name: NSNotification.Name("AppActive"), object: nil)
                    }
                }
            }
            if call.isOutgoing == true && call.hasConnected == false {
                print("Dialing")
                print(call.uuid)
                self.callStatus = "dialing"
                let formaterDate = DateFormatter()
                let formaterStartTime = DateFormatter()
                formaterDate.dateFormat = "MM/dd/yyyy"
                formaterStartTime.dateFormat = "MM/dd/yyyy HH:mm:ss"
                self.callDate = formaterDate.string(from: Date())
                self.callStart = formaterStartTime.string(from: Date())
                print(Date())
            }
            if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
                print("Incoming")
                print(call.uuid)
                self.callStatus = "incoming"
                let formaterDate = DateFormatter()
                let formaterStartTime = DateFormatter()
                formaterDate.dateFormat = "MM/dd/yyyy"
                formaterStartTime.dateFormat = "MM/dd/yyyy HH:mm:ss"
                self.callDate = formaterDate.string(from: Date())
                self.callStart = formaterStartTime.string(from: Date())
                print(Date())
            }
            if call.hasConnected == true && call.hasEnded == false {
                print("Connected")
                print(call.uuid)
                self.callPreviousStatus = self.callStatus
                self.callStatus = "connected"
                let formaterDate = DateFormatter()
                let formaterStartTime = DateFormatter()
                formaterDate.dateFormat = "MM/dd/yyyy"
                formaterStartTime.dateFormat = "MM/dd/yyyy HH:mm:ss"
                self.callDate = formaterDate.string(from: Date())
                self.callStart = formaterStartTime.string(from: Date())
                print(Date())
                }
            
            }
        }
    }
}

extension AppDelegate {

    func registerLocalNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }

    func scheduleLocalNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                print("fireNotification")
                self.fireNotification()
            }
        }
    }

    func fireNotification() {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()

        // Configure Notification Content
        notificationContent.title = "Call registrated"
        notificationContent.body = ""

        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)

        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "local_notification", content: notificationContent, trigger: notificationTrigger)

        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
            print("Notification display")
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("foreground")
        print(notification)
        completionHandler([.alert, .sound])
    }
    
}
