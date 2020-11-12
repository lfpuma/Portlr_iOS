//
//  AutoTimeTrack.swift
//  PORTLR
//
//  Created by puma on 01.05.2020.
//  Copyright © 2020 Ranksol. All rights reserved.
//

import Foundation
import UIKit

let PREF_IS_CALL_LOGGER = "PREF_IS_CALL_LOGGER"
let PREF_IS_LOCATION_ENALBE = "PREF_IS_LOCATION_ENALBE"
let PREF_IS_ACTIVE = "PREF_IS_ACTIVE"
let PREF_ISSETSTARTPAGE = "PREF_ISSETSTARTPAGE"
let PREF_WORKDAYS = "PREF_WORKDAYS"
let PREF_PROJECT_ID = "PREF_PROJECT_ID"
let PREF_PROJECT_NAME = "PREF_PROJECT_NAME"
let PREF_STARTTIME = "PREF_STARTTIME"
let PREF_ENDTIME = "PREF_ENDTIME"
let PREF_WORKLOCATION = "PREF_WORKLOCATION"
let PREF_IS_FIRST_TIME = "PREF_IS_FIRST_TIME"
let PREF_LAT = "PREF_LAT"
let PREF_LNG = "PREF_LNG"
let PREF_NOTIFICATION_TRIGGER = "PREF_NOTIFICATION_TRIGGER"

class AutoTimeTrack: NSObject {
    
    var isCallLogger: Bool!
    var isLocation: Bool!
    var isActive: Bool!
    var isSetStartPage: Bool!
    var workdays: [Bool]!
    var projectID: String!
    var projectName: String!
    var startTime: Date!
    var endTime: Date!
    var workLocation: String!
    
    var lat: Double!
    var lng: Double!
    
    var notificationTriggered: Bool!
    
    var isFirstTime: Bool!
    
    func saveObj() {
        let defaults = UserDefaults.standard
        defaults.set(isCallLogger, forKey: PREF_IS_CALL_LOGGER)
        defaults.set(isLocation, forKey: PREF_IS_LOCATION_ENALBE)
        defaults.set(isActive, forKey: PREF_IS_ACTIVE)
        defaults.set(isSetStartPage, forKey: PREF_ISSETSTARTPAGE)
        defaults.set(workdays, forKey: PREF_WORKDAYS)
        defaults.set(projectID, forKey: PREF_PROJECT_ID)
        defaults.set(projectName, forKey: PREF_PROJECT_NAME)
        defaults.set(startTime, forKey: PREF_STARTTIME)
        defaults.set(endTime, forKey: PREF_ENDTIME)
        defaults.set(workLocation, forKey: PREF_WORKLOCATION)
        defaults.set(lat, forKey: PREF_LAT)
        defaults.set(lng, forKey: PREF_LNG)
        defaults.set(notificationTriggered, forKey: PREF_NOTIFICATION_TRIGGER)
        defaults.set(false, forKey: PREF_IS_FIRST_TIME)
    }
    
    func loadObj() {
        let defaults = UserDefaults.standard
        isCallLogger = defaults.bool(forKey: PREF_IS_CALL_LOGGER)
        isLocation = defaults.bool(forKey: PREF_IS_LOCATION_ENALBE)
        isActive = defaults.bool(forKey: PREF_IS_ACTIVE)
        isSetStartPage = defaults.bool(forKey: PREF_ISSETSTARTPAGE)
        workdays = defaults.array(forKey: PREF_WORKDAYS) as? [Bool] ?? [Bool]()
        projectID = defaults.string(forKey: PREF_PROJECT_ID)
        projectName = defaults.string(forKey: PREF_PROJECT_NAME)
        startTime = defaults.object(forKey: PREF_STARTTIME) as? Date ?? Date()
        endTime = defaults.object(forKey: PREF_ENDTIME) as? Date ?? Date()
        workLocation = defaults.string(forKey: PREF_WORKLOCATION)
        lat = defaults.double(forKey: PREF_LAT)
        lng = defaults.double(forKey: PREF_LNG)
        notificationTriggered = defaults.bool(forKey: PREF_NOTIFICATION_TRIGGER)
        isFirstTime = defaults.bool(forKey: PREF_IS_FIRST_TIME)
    }
    
    func clearObj() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: PREF_IS_CALL_LOGGER)
        defaults.set(false, forKey: PREF_IS_LOCATION_ENALBE)
        defaults.set(false, forKey: PREF_IS_ACTIVE)
        defaults.set(false, forKey: PREF_ISSETSTARTPAGE)
        defaults.set([false, false, false, false, false, false, false], forKey: PREF_WORKDAYS)
        defaults.set("", forKey: PREF_PROJECT_ID)
        defaults.set("", forKey: PREF_PROJECT_NAME)
        defaults.set(DateTimeUtils.share.getStringToTime(time: "09:00:00"), forKey: PREF_STARTTIME)
        defaults.set(DateTimeUtils.share.getStringToTime(time: "16:00:00"), forKey: PREF_ENDTIME)
        defaults.set("", forKey: PREF_WORKLOCATION)
        defaults.set(0.0, forKey: PREF_LAT)
        defaults.set(0.0, forKey: PREF_LNG)
        defaults.set(false, forKey: PREF_NOTIFICATION_TRIGGER)
        defaults.set(true, forKey: PREF_IS_FIRST_TIME)
        
        CheckInOut().clearObj()
    }
    
    func isCheckCallLogger() -> Bool {
        loadObj()
        return isCallLogger
    }
    
    func getStartTime() -> Date {
        loadObj()
        return startTime
    }
    
    func getEndTime() -> Date {
        loadObj()
        return endTime
    }
    
    func isStartPageSet() -> Bool {
        return isSetStartPage
    }
    
    func removeNotification(status: Int) {
        let wday = getWeekday()
        print(wday)
        
        var weekday = 1
        if wday == 1 {
            weekday = 6
        } else {
            weekday = wday - 2
        }
        
        if status == 1 {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NOTIFICATION_START_IDS[weekday]])
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NOTIFICATION_END_IDS[weekday]])
        }
    }
    
    func registerNotifications() {
        
        CheckInOut().clearObj()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        notificationTriggered = false
        saveObj()
        
        if !isActive {
            return
        }
        
        let calendar = Calendar.current
        let startTimeComponent = calendar.dateComponents([.hour,.minute], from: startTime)
        let endTimeComponent = calendar.dateComponents([.hour,.minute], from: endTime)
        
        let title = "PORTLR"
        let startTimeNotification = "Time is \(startTimeComponent.hour!):\(startTimeComponent.minute!) - Check-in?"
        let endTimeNotification = "Time is \(endTimeComponent.hour!):\(endTimeComponent.minute!) - Check-out?"
        
        if workdays[0] {
            scheduleNotification(at: createDate(weekday: 2, hour: startTimeComponent.hour!, minute: startTimeComponent.minute!), body: startTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_START_IDS[0], identifier: NOTIFICATION_START_IDS[0])
            
            scheduleNotification(at: createDate(weekday: 2, hour: endTimeComponent.hour!, minute: endTimeComponent.minute!), body: endTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_END_IDS[0], identifier: NOTIFICATION_END_IDS[0])
        }
        
        if workdays[1] {
            scheduleNotification(at: createDate(weekday: 3, hour: startTimeComponent.hour!, minute: startTimeComponent.minute!), body: startTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_START_IDS[1], identifier: NOTIFICATION_START_IDS[1])
            
            scheduleNotification(at: createDate(weekday: 3, hour: endTimeComponent.hour!, minute: endTimeComponent.minute!), body: endTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_END_IDS[1], identifier: NOTIFICATION_END_IDS[1])
        }
        
        if workdays[2] {
            scheduleNotification(at: createDate(weekday: 4, hour: startTimeComponent.hour!, minute: startTimeComponent.minute!), body: startTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_START_IDS[2], identifier: NOTIFICATION_START_IDS[2])
            
            scheduleNotification(at: createDate(weekday: 4, hour: endTimeComponent.hour!, minute: endTimeComponent.minute!), body: endTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_END_IDS[2], identifier: NOTIFICATION_END_IDS[2])
        }
        
        if workdays[3] {
            scheduleNotification(at: createDate(weekday: 5, hour: startTimeComponent.hour!, minute: startTimeComponent.minute!), body: startTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_START_IDS[3], identifier: NOTIFICATION_START_IDS[3])
            
            scheduleNotification(at: createDate(weekday: 5, hour: endTimeComponent.hour!, minute: endTimeComponent.minute!), body: endTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_END_IDS[3], identifier: NOTIFICATION_END_IDS[3])
        }
        
        if workdays[4] {
            scheduleNotification(at: createDate(weekday: 6, hour: startTimeComponent.hour!, minute: startTimeComponent.minute!), body: startTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_START_IDS[4], identifier: NOTIFICATION_START_IDS[4])
            
            scheduleNotification(at: createDate(weekday: 6, hour: endTimeComponent.hour!, minute: endTimeComponent.minute!), body: endTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_END_IDS[4], identifier: NOTIFICATION_END_IDS[4])
        }
        
        if workdays[5] {
            scheduleNotification(at: createDate(weekday: 7, hour: startTimeComponent.hour!, minute: startTimeComponent.minute!), body: startTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_START_IDS[5], identifier: NOTIFICATION_START_IDS[5])
            
            scheduleNotification(at: createDate(weekday: 7, hour: endTimeComponent.hour!, minute: endTimeComponent.minute!), body: endTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_END_IDS[5], identifier: NOTIFICATION_END_IDS[5])
        }
        
        if workdays[6] {
            scheduleNotification(at: createDate(weekday: 1, hour: startTimeComponent.hour!, minute: startTimeComponent.minute!), body: startTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_START_IDS[6], identifier: NOTIFICATION_START_IDS[6])
            
            scheduleNotification(at: createDate(weekday: 1, hour: endTimeComponent.hour!, minute: endTimeComponent.minute!), body: endTimeNotification, titles: title, categoryIdentifier: NOTIFICATION_END_IDS[6], identifier: NOTIFICATION_END_IDS[6])
        }
        
    }
    
    func scheduleNotification(at date: Date, body: String, titles:String, categoryIdentifier: String, identifier: String) {

        let triggerWeekly = Calendar.current.dateComponents([.weekday,.hour,.minute,.second,], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = titles
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = categoryIdentifier

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("add error: \(error)")
            }
        }
    }
    
    func createDate(weekday: Int, hour: Int, minute: Int)->Date{

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.weekday = weekday // sunday = 1 ... saturday = 7
        components.second = 0
        components.weekdayOrdinal = 10
        components.timeZone = .current

        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: components)!
    }
    
    func getWeekday() -> Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.component(.weekday, from: Date())
    }
    
}
