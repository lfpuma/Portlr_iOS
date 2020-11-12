//
//  CheckINOUT.swift
//  PORTLR
//
//  Created by puma on 02.05.2020.
//  Copyright © 2020 Ranksol. All rights reserved.
//

import Foundation

let PREF_DATE = "PREF_DATE"
let PREF_CHECKIN = "PREF_CHECKIN"
let PREF_CHECKOUT = "PREF_CHECKOUT"
let PREF_START_DATE = "PREF_START_DATE"
let PREF_END_DATE = "PREF_END_DATE"

class CheckInOut: NSObject {
    var date: Date!
    var checkin: Bool!
    var checkout: Bool!
    var startDate: Date!
    var endDate: Date!
    
    func saveObj() {
        let defaults = UserDefaults.standard
        defaults.set(date, forKey: PREF_DATE)
        defaults.set(checkin, forKey: PREF_CHECKIN)
        defaults.set(checkout, forKey: PREF_CHECKOUT)
        defaults.set(startDate, forKey: PREF_START_DATE)
        defaults.set(endDate, forKey: PREF_END_DATE)
    }
    
    func loadObj() {
        let defaults = UserDefaults.standard
        date = defaults.object(forKey: PREF_DATE) as? Date ?? Date()
        checkin = defaults.bool(forKey: PREF_CHECKIN)
        checkout = defaults.bool(forKey: PREF_CHECKOUT)
        startDate = defaults.object(forKey: PREF_START_DATE) as? Date ?? Date()
        endDate = defaults.object(forKey: PREF_END_DATE) as? Date ?? Date()
    }
    
    func clearObj() {
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: PREF_DATE)
        defaults.set(false, forKey: PREF_CHECKIN)
        defaults.set(false, forKey: PREF_CHECKOUT)
        defaults.set(AutoTimeTrack().getStartTime(), forKey: PREF_START_DATE)
        defaults.set(AutoTimeTrack().getEndTime(), forKey: PREF_END_DATE)
    }
}
