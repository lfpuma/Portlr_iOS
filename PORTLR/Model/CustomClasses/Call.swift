//
//  Call.swift
//  PORTLR
//
//  Created by Hunain on 29/05/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit

class Call: NSObject,NSCoding {
    var callDate:String!
    var callStartTime: String!
    var callEndTime: String!
    var status: String!
    var duration: String!
    var clientId: String!
    var companyName: String!
    var companyId: String!
    var clientStatus: String!
    var companyURL: String!
    var callId: String!
    var callerName: String!
    var projectId: Int!
    var projectName: String!
    var taskId: Int!
    var taskName: String!
    var isDelete: Bool!
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.callDate = aDecoder.decodeObject(forKey: "callDate") as? String
        self.callStartTime = aDecoder.decodeObject(forKey: "callStartTime") as? String
        self.callEndTime = aDecoder.decodeObject(forKey: "callEndTime") as? String
        self.status = aDecoder.decodeObject(forKey: "status") as? String
        self.duration = aDecoder.decodeObject(forKey: "duration") as? String
        self.clientId = aDecoder.decodeObject(forKey: "clientId") as? String
        self.companyName = aDecoder.decodeObject(forKey: "companyName") as? String
        self.companyId = aDecoder.decodeObject(forKey: "companyId") as? String
        self.clientStatus = aDecoder.decodeObject(forKey: "clientStatus") as? String
        self.companyURL = aDecoder.decodeObject(forKey: "companyURL") as? String
        self.callId = aDecoder.decodeObject(forKey: "callId") as? String
        self.callerName = aDecoder.decodeObject(forKey: "callerName") as? String
        
        self.projectId = aDecoder.decodeObject(forKey: "projectId") as? Int
        self.projectName = aDecoder.decodeObject(forKey: "projectName") as? String
        self.taskId = aDecoder.decodeObject(forKey: "taskId") as? Int
        self.taskName = aDecoder.decodeObject(forKey: "taskName") as? String
        self.isDelete = aDecoder.decodeObject(forKey: "isDelete") as? Bool
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.callDate,forKey: "callDate")
        aCoder.encode(self.callStartTime, forKey: "callStartTime")
        aCoder.encode(self.callEndTime, forKey: "callEndTime")
        aCoder.encode(self.status, forKey: "status")
        aCoder.encode(self.duration, forKey: "duration")
        aCoder.encode(self.clientId, forKey: "clientId")
        aCoder.encode(self.companyName, forKey: "companyName")
        aCoder.encode(self.companyId, forKey: "companyId")
        aCoder.encode(self.clientStatus, forKey: "clientStatus")
        aCoder.encode(self.companyURL, forKey: "companyURL")
        aCoder.encode(self.callId, forKey: "callId")
        aCoder.encode(self.callerName, forKey: "callerName")
        
        aCoder.encode(self.projectId, forKey: "projectId")
        aCoder.encode(self.projectName, forKey: "projectName")
        aCoder.encode(self.taskId, forKey: "taskId")
        aCoder.encode(self.taskName, forKey: "taskName")
        aCoder.encode(self.isDelete, forKey: "isDelete")
    }
    
    //MARK: Archive Methods
    
    class func archiveFilePath() -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("call.archive").path
    }
    
    class func readCallFromArchive() -> [Call]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: archiveFilePath()) as? [Call]
    }
    
    class func saveCallToArchive(call: [Call]) -> Bool {
        return NSKeyedArchiver.archiveRootObject(call, toFile: archiveFilePath())
    }
    
    class func saveCall(call: Call) {
        let arrCalls = Call.readCallFromArchive()
        if arrCalls == nil {
            return
        }
        
        var newCalls = [Call]()
        for cal in arrCalls! {
            if cal.callId == call.callId {
                newCalls.append(call)
            } else {
                newCalls.append(cal)
            }
        }
        
        if Call.saveCallToArchive(call: newCalls){
        }
        
    }
    
    class func convertToTimeLog(call: Call) -> TimeLog {
        let timeLog = TimeLog()
        
        timeLog.projectId = call.projectId
        timeLog.projectName = call.projectName
        timeLog.taskId = call.taskId
        timeLog.taskName = call.taskName
        
        return timeLog
    }
    
}
