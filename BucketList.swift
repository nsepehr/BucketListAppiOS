//
//  BucketList.swift
//  BucketListCD
//
//  Created by Nima Sepehr on 12/9/15.
//  Copyright © 2015 Nima Sepehr. All rights reserved.
//

import Foundation
import CoreData
import UIKit


//TaskClass
class BucketList<T: TaskEntity>: MyData<T> {
    
    let sortOrder = "displayOrder"
    var entityList: Array<T>!
    let fileManager = NSFileManager.defaultManager()
    
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
    
    func addImageForEntity(entity: TaskEntity, image: UIImage) {
        // Get the image data and create the image file at the app document directory
        let ext: String = "png"
        let thisData: NSData = UIImagePNGRepresentation(image)!
        let imageRelativeDir = self.getImageDirectoryForEntity(entity)
        let imageFullDir = self.getImageDirectoryForEntity(entity, fullPath: true)
        var isDir : ObjCBool = false
        if fileManager.fileExistsAtPath(imageFullDir, isDirectory: &isDir) {
            if isDir {
                // Path exists and it's a directory
            } else {
                // Path exists, but it's not a directory!!
                NSLog("ERROR: Expected path \(imageFullDir) to be a directory")
                return
            }
        } else {
            // The path doesn't exist, so create it
            do {
                try self.fileManager.createDirectoryAtPath(imageFullDir, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory for task \(entity.name!) images: \(error)")
                return
            }
        }
        var imageName: NSString = entity.name!
        imageName = imageName.stringByAppendingPathExtension(ext)!
        var imageFullPath: String = (imageFullDir as NSString).stringByAppendingPathComponent(imageName as String)
        var i = 0
        while fileManager.fileExistsAtPath(imageFullPath) {
            imageName = "\(entity.name!).\(i)"
            imageName = imageName.stringByAppendingPathExtension(ext)!
            imageFullPath = (imageFullDir as NSString).stringByAppendingPathComponent(imageName as String)
            i++
        }
        self.fileManager.createFileAtPath(imageFullPath, contents: thisData, attributes: nil)
        
        // Update the URL string array for the tasks
        //   Have to get all the URLs as string array, add the new image url and then save
        //   We don't save the whole url, just the relative path from the User document directory
        let saveRelativeImageUrl = (imageRelativeDir as NSString).stringByAppendingPathComponent(imageName as String)
        var urls: [String]? = self.getAllImageUrls(entity)
        if urls == nil {
            urls = [saveRelativeImageUrl]
        } else {
            urls!.append(saveRelativeImageUrl)
        }
        
        let urlData: NSData = NSKeyedArchiver.archivedDataWithRootObject(urls!)
        entity.images = urlData
        self.saveEntities()
    }
    
    func removeImageForEntityForIndex(entity: TaskEntity, index: Int) {
        // Will remove the picture from the array index of images
        // Update the URL string array for the tasks
        //   Have to get all the URLs as string array, remove the url for the specified index
        var urls: [String]? = self.getAllImageUrls(entity)
        if urls == nil {
            print("Unexpectedly fount nil urls array when attempting to remove for task \(entity.name)")
            return
        }
        
        if urls!.count < index {
            print("The array of images is smaller than the index \(index) specified for removing image for task \(entity.name)")
            return
        }
        let imageUrl: String = self.getImageFullPath(urls![index])
        do {
            try self.fileManager.removeItemAtPath(imageUrl)
            urls!.removeAtIndex(index)
            let urlNSData: NSData = NSKeyedArchiver.archivedDataWithRootObject(urls!)
            entity.images = urlNSData
            self.saveEntities()
        } catch let error as NSError {
            NSLog("Failed to remove image at url \(imageUrl): \(error)")
        }
    }
    
    func getAllImageUrls(forEntity: TaskEntity) -> ([String]?) {
        var urls: [String]?
        if forEntity.images != nil {
            urls = NSKeyedUnarchiver.unarchiveObjectWithData(forEntity.images!) as? [String]
        }
        return urls
    }
    
    func getImageForEntityForIndex(entity: TaskEntity, index: Int) -> UIImage? {
        print("Getting image for task \(entity.name!) for index \(index)")
        let allImages: [String]? = self.getAllImageUrls(entity)
        if allImages == nil {
            print("No image for task")
            return nil
        }
        //print(allImages!)
        let imageUrl: String = self.getImageFullPath(allImages![index])
        let image: UIImage? = self.getImageForUrl(imageUrl)
        return image
    }
    
    func getImageForUrl(imageUrl: String) -> UIImage? {
        // Images are relative paths to the document directory
        print("Getting image for url \(imageUrl)")
        if let image = UIImage(contentsOfFile: imageUrl) {
            return image
        }
        return nil
    }
    
    
    func getImageDirectoryForEntity(entity: TaskEntity, fullPath: Bool = false) -> String {
        let general = "images"
        var dirName = entity.name! as NSString
        dirName = dirName.stringByAppendingPathComponent(general) as NSString
        if fullPath {
            return self.getImageFullPath(dirName as String)
        }
        return dirName as String
    }

    
    func getImageFullPath(imageRelativePath: String) -> String {
        let doc = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        return doc.stringByAppendingPathComponent(imageRelativePath)
    }
}