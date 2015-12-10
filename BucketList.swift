//
//  BucketList.swift
//  BucketListCD
//
//  Created by Nima Sepehr on 12/9/15.
//  Copyright © 2015 Nima Sepehr. All rights reserved.
//

import Foundation



//TaskClass
class BucketList<T: TaskEntity>: MyData<T> {
    
    let sortOrder = "displayOrder"
    var entityList: Array<T>!
    
    override init() {
        super.init()
    }
    
    func getAllEntitiesByDisplayOrder() -> Array<T> {
        let sortDescriptor = NSSortDescriptor(key: sortOrder, ascending: true)
        self.entityList = self.getAllEntitiesAndSortBy(sortedBy: sortDescriptor)
        return self.entityList
    }
    
    func addTaskWithName(taskName: String) -> (TaskEntity) {
        let task = self.createEntity()
        task.name = taskName
        task.createdDate = NSDate()
        task.displayOrder = self.entityList.count + 1
        
        self.saveEntities()
        self.entityList.append(task)
        
        return task
    }
}