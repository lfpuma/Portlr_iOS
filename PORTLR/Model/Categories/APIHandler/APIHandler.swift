//
//  APIHandler.swift
//  Proenti
//
//  Created by Hunain on 17/01/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
//import AFNetworking

private let SharedInstance = APIHandler()

enum Endpoint : String {
    
    //MARK: User
    case login                  = "/api/Authorize/isValidUser"
    case token                  = "/api/Account/Authenticate"
    
    //MARK: Company
    case companyNames           = "/api/services/app/client/GetAllClients"
    
    //MARK: Projects
    case projectNames           = "/api/services/app/project/GetProjectsByUserId"
    
    //MARK: Time Sheet
    case timeSheet              = "/api/services/app/timesheet/createorupdatetimesheet"
    
    case getTimeSheet           = "/api/services/app/timesheet/GetTimesheetByUserId"
    
    case getExtraTimeSheet      = "/api/services/app/timesheet/GetAllTimesheets"
    
    //MARK: TASKS
    case task                   = "/api/services/app/task/GetProjectsTasks"
}

class APIHandler: NSObject {
    
    var baseApiPath:String!
    
    class var sharedInstance : APIHandler {
        return SharedInstance
    }
    
    override init() {
       //https://test.portlr.dk
    }
    
    //MARK: User
    
    //Login
    func loginUser(url:String,email:String,password:String,completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void){
        AppUtility?.showHud()
        self.baseApiPath = url
        AppUtility?.saveObject(obj: url, forKey: strURL)
        var parameters = [String : AnyObject]()
        
        parameters = [
            "emailAddress" : email as AnyObject,
            "password" : password as AnyObject
        ]
        
        let finalURL = "\(self.baseApiPath!)\(Endpoint.login.rawValue)"
        Alamofire.request(finalURL, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (response) in
            if response.result.isSuccess
            {
                do {
                    let json = try JSONSerialization.jsonObject(with: response.result.value!, options: .mutableContainers)
                    let dict = json as? NSDictionary
                    print(dict)
                    completionHandler(true, dict)
                } catch {
                    completionHandler(false, nil)
                }
            }else{
              completionHandler(false, nil)
            }
            AppUtility?.hideHud()
        }
    }
    
    func getTokenKey(apiKey:String,apiSecret:String,completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void){
        AppUtility?.showHud()
        self.baseApiPath = UserDefaults.standard.string(forKey:strURL)
        var parameters = [String : AnyObject]()
        
        parameters = [
            "apiKey" : apiKey as AnyObject,
            "apiSecret" : apiSecret as AnyObject
        ]
        
        let finalURL = "\(self.baseApiPath!)\(Endpoint.token.rawValue)"
        Alamofire.request(finalURL, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (response) in
            if response.result.isSuccess
            {
                do {
                    let json = try JSONSerialization.jsonObject(with: response.result.value!, options: .mutableContainers)
                    let dict = json as? NSDictionary
                    print(dict)
                    completionHandler(true, dict)
                } catch {
                    completionHandler(false, nil)
                }
            }else{
                completionHandler(false, nil)
            }
            AppUtility?.hideHud()
        }
    }
    
    func getCompanyNames(completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void){
        AppUtility?.showHud()
        self.baseApiPath = UserDefaults.standard.string(forKey:strURL)
        var auth = ""
        if let Token = AppUtility?.getObject(forKey: strToken){
            auth = Token
        }
        let header : [String : Any] = ["Authorization" : "Bearer \(auth)" ]
        let finalURL = "\(self.baseApiPath!)\(Endpoint.companyNames.rawValue)"
        Alamofire.request(finalURL, method: .post, parameters: nil, encoding: URLEncoding.default, headers: header as? HTTPHeaders).responseData { (response) in
            if response.result.isSuccess
            {
                do {
                    let json = try JSONSerialization.jsonObject(with: response.result.value!, options: .mutableContainers)
                    let dict = json as? NSDictionary
                    print(dict)
                    completionHandler(true, dict)
                } catch {
                    completionHandler(false, nil)
                }
            }else{
                completionHandler(false, nil)
            }
            AppUtility?.hideHud()
        }
    }
    
    func getProjectNames(clientID:String,completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void){
        AppUtility?.showHud()
        self.baseApiPath = UserDefaults.standard.string(forKey:strURL)
        var auth = ""
        if let Token = AppUtility?.getObject(forKey: strToken){
            auth = Token
        }
        let header : [String : Any] = ["Authorization" : "Bearer \(auth)" ]
        let finalURL = "\(self.baseApiPath!)\(Endpoint.projectNames.rawValue)?userId=\(clientID)"
        Alamofire.request(finalURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header as? HTTPHeaders).responseData { (response) in
            if response.result.isSuccess
            {
                do {
                    let json = try JSONSerialization.jsonObject(with: response.result.value!, options: .mutableContainers)
                    let dict = json as? NSDictionary
                    print(dict)
                    completionHandler(true, dict)
                } catch {
                    completionHandler(false, nil)
                }
            }else{
                completionHandler(false, nil)
            }
            AppUtility?.hideHud()
        }
    }
    
    func getTasks(clientID:String, projectID: String, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void){
        AppUtility?.showHud()
        self.baseApiPath = UserDefaults.standard.string(forKey:strURL)
        var auth = ""
        if let Token = AppUtility?.getObject(forKey: strToken){
            auth = Token
        }
        let header : [String : Any] = ["Authorization" : "Bearer \(auth)" ]
        let finalURL = "\(self.baseApiPath!)\(Endpoint.task.rawValue)?UserId=\(clientID)&ProjectId=\(projectID)"
        Alamofire.request(finalURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header as? HTTPHeaders).responseData { (response) in
            if response.result.isSuccess
            {
                do {
                    let json = try JSONSerialization.jsonObject(with: response.result.value!, options: .mutableContainers)
                    let dict = json as? NSDictionary
                    print(dict)
                    completionHandler(true, dict)
                } catch {
                    completionHandler(false, nil)
                }
            }else{
                completionHandler(false, nil)
            }
            AppUtility?.hideHud()
        }
    }
    
    func setTimeSheet(projectID:String,userID:String,endedAt:String,hours:String,roundedHours:String,spentAt:String,startedAt:String,completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void){
        AppUtility?.showHud()
        self.baseApiPath = UserDefaults.standard.string(forKey:strURL)
        var parameters = [String : AnyObject]()
        
        parameters = [
            "projectId" : projectID as AnyObject,
            "userId" : userID as AnyObject,
            "endedAt" : endedAt as AnyObject,
            "hours" : hours as AnyObject,
            "roundedHours" : roundedHours as AnyObject,
            "isInvoice" : "false" as AnyObject,
            "notes" : "phone conversation" as AnyObject,
            "spentAt" : spentAt as AnyObject,
            "startedAt" : startedAt as AnyObject,
        ]
        print(parameters)
        var auth = ""
        if let Token = AppUtility?.getObject(forKey: strToken){
            auth = Token
        }
        let header : [String : Any] = ["Authorization" : "Bearer \(auth)" ]
        let finalURL = "\(self.baseApiPath!)\(Endpoint.timeSheet.rawValue)"
        Alamofire.request(finalURL, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: header as? HTTPHeaders).responseData { (response) in
            if response.result.isSuccess
            {
                do {
                    let json = try JSONSerialization.jsonObject(with: response.result.value!, options: .mutableContainers)
                    let dict = json as? NSDictionary
                    print(dict)
                    completionHandler(true, dict)
                } catch {
                    completionHandler(false, nil)
                }
            }else{
                completionHandler(false, nil)
            }
            AppUtility?.hideHud()
        }
    }
    
    func newSetTimeSheet(timeSheetId: Int, projectID:String,taskID:String,userID:String,endedAt:String,hours:String,roundedHours:String,spentAt:String,startedAt:String,notes: String, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void){
        AppUtility?.showHud()
        self.baseApiPath = UserDefaults.standard.string(forKey:strURL)
        var parameters = [String : AnyObject]()
        
        if timeSheetId == 0 {
            parameters = [
                "projectId" : projectID as AnyObject,
                "taskId" : taskID as AnyObject,
                "userId" : userID as AnyObject,
                "endedAt" : endedAt as AnyObject,
                "hours" : hours as AnyObject,
                "roundedHours" : roundedHours as AnyObject,
                "isInvoice" : "false" as AnyObject,
                "notes" : notes as AnyObject,
                "spentAt" : spentAt as AnyObject,
                "startedAt" : startedAt as AnyObject,
            ]
        } else {
            parameters = [
                "id": timeSheetId as AnyObject,
                "projectId" : projectID as AnyObject,
                "taskId" : taskID as AnyObject,
                "userId" : userID as AnyObject,
                "endedAt" : endedAt as AnyObject,
                "hours" : hours as AnyObject,
                "roundedHours" : roundedHours as AnyObject,
                "isInvoice" : "false" as AnyObject,
                "notes" : notes as AnyObject,
                "spentAt" : spentAt as AnyObject,
                "startedAt" : startedAt as AnyObject,
            ]
        }
        
        print(parameters)
        var auth = ""
        if let Token = AppUtility?.getObject(forKey: strToken){
            auth = Token
        }
        let header : [String : Any] = ["Authorization" : "Bearer \(auth)" ]
        let finalURL = "\(self.baseApiPath!)\(Endpoint.timeSheet.rawValue)"
        
        
        Alamofire.request(finalURL, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: header as? HTTPHeaders).responseData { (response) in
            if response.result.isSuccess
            {
                do {
                    let json = try JSONSerialization.jsonObject(with: response.result.value!, options: .mutableContainers)
                    let dict = json as? NSDictionary
                    print(dict)
                    completionHandler(true, dict)
                } catch {
                    completionHandler(false, nil)
                }
            }else{
                completionHandler(false, nil)
            }
            AppUtility?.hideHud()
        }
    }
    
    func getTimeSheets(userId:String,date: String, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void){
//        AppUtility?.showHud()
        self.baseApiPath = UserDefaults.standard.string(forKey:strURL)
        var auth = ""
        if let Token = AppUtility?.getObject(forKey: strToken){
            auth = Token
        }
        let header : [String : Any] = ["Authorization" : "Bearer \(auth)" ]
        let finalURL = "\(self.baseApiPath!)\(Endpoint.getTimeSheet.rawValue)?UserId=\(userId)&Date=\(date)"
        Alamofire.request(finalURL, method: .post, parameters: nil, encoding: URLEncoding.default, headers: header as? HTTPHeaders).responseData { (response) in
            if response.result.isSuccess
            {
                do {
                    let json = try JSONSerialization.jsonObject(with: response.result.value!, options: .mutableContainers)
                    let dict = json as? NSDictionary
                    print(dict)
                    completionHandler(true, dict)
                } catch {
                    completionHandler(false, nil)
                }
            }else{
                completionHandler(false, nil)
            }
//            AppUtility?.hideHud()
        }
    }
    
    func getExtraTimeSheets(userId:String,completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void){
        AppUtility?.showHud()
        self.baseApiPath = UserDefaults.standard.string(forKey:strURL)
        var auth = ""
        if let Token = AppUtility?.getObject(forKey: strToken){
            auth = Token
        }
        let header : [String : Any] = ["Authorization" : "Bearer \(auth)" ]
        let finalURL = "\(self.baseApiPath!)\(Endpoint.getExtraTimeSheet.rawValue)?UserId=\(userId)"
        Alamofire.request(finalURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header as? HTTPHeaders).responseData { (response) in
            if response.result.isSuccess
            {
                do {
                    let json = try JSONSerialization.jsonObject(with: response.result.value!, options: .mutableContainers)
                    let dict = json as? NSDictionary
                    print(dict)
                    completionHandler(true, dict)
                } catch {
                    completionHandler(false, nil)
                }
            }else{
                completionHandler(false, nil)
            }
            AppUtility?.hideHud()
        }
    }
    
}
