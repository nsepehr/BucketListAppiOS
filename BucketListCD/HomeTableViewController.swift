//
//  HomeTableViewController.swift
//  BucketListCD
//
//  Created by Nima Sepehr on 12/8/15.
//  Copyright © 2015 Nima Sepehr. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    // Task Data related
    var bucket = BucketList()
    let cellIdentifier = "TaskCell"
    
    // Date Formatter
    let dateFormat: NSDateFormatterStyle = .ShortStyle
    var createDateFormat: NSDateFormatter {
        let format = NSDateFormatter()
        format.dateStyle = dateFormat
        return format
    }
    
    // Image
    let defaultTaskImage = UIImage(named: "defaultTaskImage")
    let completedTaskImage = UIImage(named: "completedTasksImage")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bucket.getAllEntitiesByDisplayOrder()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bucket.entityList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HomeTableViewCell
        let thisTask = self.bucket.entityList[indexPath.row]
        
        // Configure the cell...
        cell.taskNameLabel.text = thisTask.name
        cell.createDateLabel.text = createDateFormat.stringFromDate(thisTask.createdDate!)
        if (thisTask.completed) {
            cell.taskimage.image = completedTaskImage
        } else {
            cell.taskimage.image = defaultTaskImage
        }
        
        return cell
    }
    

    // MARK: - Navigation

    @IBAction func unwindSaveTask(segue: UIStoryboardSegue) {
        print("I'm unwinded and saving task")
        
        // Get the task name and add to the table
        let source = segue.sourceViewController as! AddTaskViewController
        let taskName: String! = source.textField.text
        self.bucket.addTaskWithName(taskName)
        
        // Update the table rows
        let indexPath: NSIndexPath = NSIndexPath(forRow: (self.bucket.entityList.count-1) , inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
    
    @IBAction func unwindCancelTask(segue: UIStoryboardSegue) {
        print("I unwinded, but canceled task")
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */



}
