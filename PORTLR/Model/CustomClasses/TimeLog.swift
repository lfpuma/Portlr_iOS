//
//  TimeLog.swift
//  PORTLR
//
//  Created by puma on 07.04.2020.
//  Copyright © 2020 Ranksol. All rights reserved.
//

import Foundation

class TimeLog: NSObject {
    var timesheetId: Int!
    var userId: Int!
    var projectId: Int!
    var projectName: String!
    var taskId: Int!
    var taskName: String!
    var comment: String!
    var startAt: String!
    var endAt: String!
    var hours: Double!
    var spentAt: String!
    var creationTime: Date!
    
    func filtered(time: String) -> Bool {
        return DateTimeUtils.share.getLocalDateString(date: creationTime) == time
    }
    
}
