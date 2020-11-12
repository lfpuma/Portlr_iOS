//
//  Project.swift
//  PORTLR
//
//  Created by puma on 06.04.2020.
//  Copyright © 2020 Ranksol. All rights reserved.
//

import Foundation

class Project: NSObject,NSCoding {
    var userId: Int!
    var name: String!

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        self.userId = aDecoder.decodeObject(forKey: "id") as? Int
        self.name = aDecoder.decodeObject(forKey: "name") as? String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.userId,forKey: "id")
        aCoder.encode(self.name, forKey: "name")
    }
}
