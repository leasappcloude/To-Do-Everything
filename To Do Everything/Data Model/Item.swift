//
//  Item.swift
//  To Do Everything
//
//  Created by Lea Gnatzig on 16.07.18.
//  Copyright © 2018 Lea Gnatzig. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    }

