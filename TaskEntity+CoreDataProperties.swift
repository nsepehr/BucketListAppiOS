//
//  TaskEntity+CoreDataProperties.swift
//  BucketListCD
//
//  Created by Nima Sepehr on 12/9/15.
//  Copyright © 2015 Nima Sepehr. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TaskEntity {

    @NSManaged var about: String?
    @NSManaged var completed: Bool
    @NSManaged var completedDate: NSDate?
    @NSManaged var createdDate: NSDate?
    @NSManaged var images: NSData?
    @NSManaged var locationLatitude: Double
    @NSManaged var locationLongitude: Double
    @NSManaged var locationName: String?
    @NSManaged var name: String?
    @NSManaged var displayOrder: NSNumber?

}
