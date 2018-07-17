//
//  Category.swift
//  To Do Everything
//
//  Created by Lea Gnatzig on 16.07.18.
//  Copyright © 2018 Lea Gnatzig. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
