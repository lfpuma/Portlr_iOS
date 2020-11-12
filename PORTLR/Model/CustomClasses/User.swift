//
//  User.swift
//  UnisLinker
//
//  Created by BILAL on 18/03/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit

class User: NSObject,NSCoding {
    var userId:String!
    var email: String!
    /*var firstname: String!
    var lastname: String!
    var email_verified_at:String!
    var stripe_id: String!
    var card_brand:String!
    var created_at:String!
    var updated_at : String!
    var card_last_four:String!
    var trial_ends_at:String!
    var type:String!
    var status:String!
    var isFree:String!
    var avatar:String!*/
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.userId = aDecoder.decodeObject(forKey: "id") as? String
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        /*self.firstname = aDecoder.decodeObject(forKey: "firstname") as? String
        self.lastname = aDecoder.decodeObject(forKey: "lastname") as? String
        self.email_verified_at = aDecoder.decodeObject(forKey: "email_verified_at") as? String
        self.stripe_id = aDecoder.decodeObject(forKey: "stripe_id") as? String
        self.card_brand = aDecoder.decodeObject(forKey: "card_brand") as? String
        self.created_at = aDecoder.decodeObject(forKey: "created_at") as? String
        self.updated_at = aDecoder.decodeObject(forKey: "updated_at") as? String
        self.card_last_four = aDecoder.decodeObject(forKey: "card_last_four") as? String
        self.trial_ends_at = aDecoder.decodeObject(forKey: "trial_ends_at") as? String
        self.type = aDecoder.decodeObject(forKey: "type") as? String
        self.status = aDecoder.decodeObject(forKey: "status") as? String
        self.isFree = aDecoder.decodeObject(forKey: "isFree") as? String
        self.avatar = aDecoder.decodeObject(forKey: "avatar") as? String*/
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.userId,forKey: "id")
        aCoder.encode(self.email, forKey: "email")
        /*aCoder.encode(self.firstname, forKey: "firstname")
        aCoder.encode(self.lastname, forKey: "lastname")
        aCoder.encode(self.email_verified_at, forKey: "email_verified_at")
        aCoder.encode(self.stripe_id, forKey: "stripe_id")
        aCoder.encode(self.card_brand, forKey: "card_brand")
        aCoder.encode(self.created_at, forKey: "created_at")
        aCoder.encode(self.updated_at, forKey: "updated_at")
        aCoder.encode(self.card_last_four, forKey: "card_last_four")
        aCoder.encode(self.trial_ends_at, forKey: "trial_ends_at")
        aCoder.encode(self.type, forKey: "type")
        aCoder.encode(self.status, forKey: "status")
        aCoder.encode(self.isFree, forKey: "isFree")
        aCoder.encode(self.avatar, forKey: "avatar")*/
    }
    
    
    
    
    //MARK: Archive Methods
    class func archiveFilePath() -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("user.archive").path
    }
    
    class func readUserFromArchive() -> [User]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: archiveFilePath()) as? [User]
    }
    
    class func saveUserToArchive(user: [User]) -> Bool {
        return NSKeyedArchiver.archiveRootObject(user, toFile: archiveFilePath())
    }
    
}
