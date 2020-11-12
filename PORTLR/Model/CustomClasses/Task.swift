//
//  Task.swift
//  PORTLR
//
//  Created by puma on 07.04.2020.
//  Copyright © 2020 Ranksol. All rights reserved.
//

import Foundation

class Task: NSObject,NSCoding {
    var id: Int!
    var title: String!

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as? Int
        self.title = aDecoder.decodeObject(forKey: "title") as? String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id,forKey: "id")
        aCoder.encode(self.title, forKey: "title")
    }
}
