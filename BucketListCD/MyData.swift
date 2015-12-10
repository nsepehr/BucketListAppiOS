//
//  MyData.swift
//  BucketListCD
//
//  Created by Nima Sepehr on 12/8/15.
//  Copyright © 2015 Nima Sepehr. All rights reserved.
//

import Foundation
import CoreData

class MyData<T: NSManagedObject>: DataHandler<T> {
    
    override init() {
        super.init()
        self.dbName = "BucketListCD"
    }
}
