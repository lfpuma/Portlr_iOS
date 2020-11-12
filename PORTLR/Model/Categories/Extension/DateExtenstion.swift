//
//  DateExtenstion.swift
//  PORTLR
//
//  Created by Hunain on 29/05/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import Foundation
extension Date {
    
    func offsetFrom(dateFrom : Date,dateTo:Date) -> String {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: dateFrom, to: dateTo);
        
        let seconds = "\(difference.second ?? 0)s"
        let minutes = "\(difference.minute ?? 0)m" + ":" + seconds
        let hours = "\(difference.hour ?? 0)h" + ":" + minutes
        let days = "\(difference.day ?? 0)d" + ":" + hours
        
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        if let second = difference.second, second > 0 { return seconds }
        return ""
    }
    
}
