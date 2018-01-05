//
//  Account.swift
//  kituraRegistration
//
//  Created by Siavash on 5/1/18.
//

import Foundation
import Meow

class Account: Model {
    
    var _id: ObjectId = ObjectId()
    let email: String
    let pwd: String
    
    init(with document: Document) {
        self.email = document[AccountObjectKey.email] as! String
        self.pwd = document[AccountObjectKey.pwd] as! String
    }
}
