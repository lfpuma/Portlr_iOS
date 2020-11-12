//
//  DateUtils.swift
//  PORTLR
//
//  Created by puma on 08.04.2020.
//  Copyright © 2020 Ranksol. All rights reserved.
//

import Foundation

import Foundation

class DateTimeUtils {
    static var share = DateTimeUtils()
    private init() {}
    
    let SERVERPATTERN = "yyyy-MM-dd'T'HH:mm:ss"
    
    func ServerToLocalDate(date:String!) -> Date {
        if date == nil || date.isEmpty {
            return Date()
        }
        var newDate = date!
        while newDate.contains(".") {
            newDate.removeLast()
        }
        if newDate.contains("Z") {
            newDate.removeLast()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = SERVERPATTERN
        return dateFormatter.date(from: newDate) ?? Date()
    }
    
    func getLocalDateString(date: Date) -> String {
         let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: date)
    }
    
    func getStringToTime(time: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.date(from: time) ?? Date()
    }
    
    func getIntervalTime(timeStr: String) -> Int {
        if(timeStr.contains(":")) {
            let list = timeStr.split(separator: ":")
            if list.count != 2 {
                return -1
            }
            return (Int(list[0]) ?? 0) * 3600 + (Int(list[1]) ?? 0) * 60
        } else {
            return -1
        }
    }
    
    func convertLocalDotToServerDotTime(timeStr: String) -> Double {
        var time = 0.0
        
        let list = timeStr.split(separator: ".")
        if list.count != 2 {
            return 0
        }
        let hours = Double(list[0]) ?? 0
        let mins = Double(list[1]) ?? 0
        
        time = hours + (100 * (mins / 60.0)).rounded() / 100
        return time
    }
    
    func getServerTimeForPost(timeStr: String) -> String {
        let time = convertLocalDotToServerDotTime(timeStr: timeStr)
        return String(time)
//        return timeStr
    }
    
    func sumServerTime(sum: String, time: Double?) -> String {
        let timeStr = getLocalTimeFromServer(time: time)
        let op1 = separateTime(timeStr: sum)
        let op2 = separateTime(timeStr: timeStr)
        let hour = op1[0] + op2[0]
        let min = op1[1] + op2[1]
        var finalHStr = ""
        var finalMStr = ""
        if min < 60 {
            finalHStr = String(hour)
            finalMStr = String(min)
        } else {
            finalHStr = String(hour + 1)
            finalMStr = String(min - 60)
        }
        
        if finalHStr.count == 1 {
            finalHStr = "0" + finalHStr
        }
        
        if finalMStr.count == 1 {
            finalMStr = "0" + finalMStr
        }
        
        return "\(finalHStr):\(finalMStr)"
    }
    
    func separateTime(timeStr: String) -> [Int] {
        let list = timeStr.split(separator: ":")
        if list.count != 2 {
            return [0, 0]
        }
        
        return [(Int(String(list[0])) ?? 0), (Int(String(list[1])) ?? 0)]
    }
    
    func getLocalTimeFromServer(time: Double?) -> String {
        
//        if time == nil {
//            return "00:00"
//        }
//        let timeStr = String(time!)
//        let list = timeStr.split(separator: ".")
//        if list.count != 2 {
//            return "00:00"
//        }
//
//        var hourStr = list[0]
//        if hourStr.count == 1 {
//            hourStr = "0" + hourStr
//        }
//
//        var miStr = list[1]
//        if miStr.count == 1 {
//            miStr = miStr + "0"
//        }
//
//        return "\(hourStr):\(miStr)"
        
        if time == nil {
            return "00:00"
        }
        let timeStr = String(time!)
        let list = timeStr.split(separator: ".")
        if list.count != 2 {
            return "00:00"
        }

        var hourStr = list[0]
        if hourStr.count == 1 {
            hourStr = "0" + hourStr
        }

        let min = time! - Double(Int(time!))
        var minStr = String(Int(round(min * 60)))
        if minStr.count == 1 {
            minStr = "0" + minStr
        }
        return "\(hourStr):\(minStr)"
    }
    
    
    func timeCompare(time1: Date, time2: Date) -> Bool {
        let calendar = Calendar.current
        let newDateComponents = calendar.dateComponents([.hour, .minute], from: time1)
        let newDate1Components = calendar.dateComponents([.hour, .minute], from: time2)

        return (newDateComponents.hour! * 60 + newDateComponents.minute!) > (newDate1Components.hour! * 60 + newDate1Components.minute!)
    }
}
