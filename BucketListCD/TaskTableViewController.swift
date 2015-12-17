//
//  TaskTableViewController.swift
//  BucketListCD
//
//  Created by Nima Sepehr on 12/9/15.
//  Copyright © 2015 Nima Sepehr. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

private let toLocationSearch = "ToLocationSearch"
private let toPictureGallery = "ToPhotoGallery"

enum TaskTableCells: String {
    case About, Status, Location, Memories
}

protocol HomeTableDelegate {
    
    func updateHomeCellImage (forTask: TaskEntity)
}



class TaskTableViewController: UITableViewController, CLLocationManagerDelegate, UISearchBarDelegate, UITextViewDelegate, TaskTableDelegate {
    
    var taskEntity: TaskEntity!
    var bucket: BucketList<TaskEntity>!
    var delegate: HomeTableDelegate?
    
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var statusButton: UISwitch!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBAction func statusButtonChanged(sender: AnyObject) {
        self.taskEntity.completed = self.statusButton.on
        self.bucket.saveEntities()
        self.delegate?.updateHomeCellImage(taskEntity)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Text View Style
        self.descriptionTextField.layer.cornerRadius = 5
        self.descriptionTextField.layer.borderWidth = 1
        self.descriptionTextField.layer.borderColor = UIColor.purpleColor().CGColor
        
        // Setting the delegate to this class so we can call the appropriate methods
        self.descriptionTextField.delegate = self
        
        // Set the task values if defined
        if self.taskEntity.about != nil {
            self.descriptionTextField.text = taskEntity.about
            self.bucket.saveEntities()
        }
        
        self.statusButton.on = self.taskEntity.completed
        
        // Gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGestureSelector:")
        tapGesture.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture)
        
        // The Nav bar info
        self.navigationItem.prompt = self.taskEntity.name
        
        // Map view update
        let myLatitude: Double? = taskEntity.locationLatitude
        let myLongitude: Double? = taskEntity.locationLongitude
        if myLatitude != 0 && myLongitude != 0 {
            let myCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLatitude!, myLongitude!)
            let myLocation = MKPointAnnotation()
            myLocation.coordinate = myCoordinates
            myLocation.title = taskEntity.name
            mapView.addAnnotation(myLocation)
            self.setMapZoom(myLocation)
            self.locationLabel.text = taskEntity.locationName
        }

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
    
    func textViewDidEndEditing(textView: UITextView) {
        print("Table editing ended")
        self.taskEntity.about = self.descriptionTextField.text
        self.bucket.saveEntities()
        self.descriptionTextField.resignFirstResponder()
    }
    
    func tapGestureSelector(gestureRecognizer: UIGestureRecognizer) {
        //print("Touches began in table view")
        self.tableView.endEditing(true)
    }
    
    func updateLocationMap(forEntity: TaskEntity) {
        // When user searches a location, this will update the update
        print("User wants to update table for location \(forEntity.locationName) ")
        let myLatitude: Double? = forEntity.locationLatitude
        let myLongitude: Double? = forEntity.locationLongitude
        if myLatitude != 0 && myLongitude != 0 {
            let myCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLatitude!, myLongitude!)
            let myLocation = MKPointAnnotation()
            myLocation.coordinate = myCoordinates
            myLocation.title = forEntity.name
            self.mapView.addAnnotation(myLocation)
            self.setMapZoom(myLocation)
            self.locationLabel.text = forEntity.locationName
        }
        
        let indexPath: [NSIndexPath] = [
            NSIndexPath(forItem: 0, inSection: TaskTableCells.Location.hashValue),
            NSIndexPath(forItem: 1, inSection: TaskTableCells.Location.hashValue)
        ]
        self.tableView.reloadRowsAtIndexPaths(indexPath, withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func setMapZoom (annotation: MKPointAnnotation) -> () {
        let altitudeDelta: CLLocationDegrees = 0.5
        let longitudeDelta: CLLocationDegrees = 0.5
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(altitudeDelta, longitudeDelta)
        
        let region: MKCoordinateRegion = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == toLocationSearch {
            let tvc = segue.destinationViewController as! LocationSearchViewController
            tvc.taskEntity = self.taskEntity
            tvc.bucket = self.bucket
            tvc.delegate = self
        } else if segue.identifier == toPictureGallery {
            let tvc = segue.destinationViewController as! PhotoGalleryCollectionViewController
            tvc.taskEntity = self.taskEntity
            tvc.bucket = self.bucket
        }
    }
    
    @IBAction func unwindToTaskView(segue: UIStoryboardSegue) {
        print("Unwinded to Task View")
    }
    



    /* We're making the  cells static
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
