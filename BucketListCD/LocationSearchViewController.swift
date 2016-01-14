//
//  LocationSearchViewController.swift
//  BucketListCD
//
//  Created by Nima Sepehr on 12/10/15.
//  Copyright © 2015 Nima Sepehr. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol TaskTableDelegate {
    
    func updateLocationMap(forTask: TaskEntity)
}


class LocationSearchViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {

    private let locationManager = CLLocationManager()
    var location: MKPointAnnotation?
    var locationName: String?
    var taskEntity: TaskEntity!
    var bucket: BucketList<TaskEntity>!
    var delegate: TaskTableDelegate?
    
    // GUI buttons
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
        
        searchBar.delegate = self
        
        // The Nav bar info
        self.navigationItem.prompt = self.taskEntity.name
        
        let myLatitude: Double? = taskEntity.locationLatitude
        let myLongitude: Double? = taskEntity.locationLongitude
        if myLatitude != 0 && myLongitude != 0 {
            let myCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLatitude!, myLongitude!)
            let myLocation = MKPointAnnotation()
            myLocation.coordinate = myCoordinates
            location = myLocation
            mapView.addAnnotation(location!)
            self.setMapZoom(location!)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("Authorization status changed to \(status.rawValue)")
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        default:
            locationManager.stopUpdatingLocation()
            mapView.showsUserLocation = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let errorType = error.code == CLError.Denied.rawValue ? "Access Denied" : "ERROR: \(error.code.description)"
        let alertController = UIAlertController(title: "Location Manager Error", message: errorType, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Cancel, handler: {action in})
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("Inside the searchBarSearchButtonClicked function")
        // Get the location entered in search bar and drop a pin on map
        searchBar.resignFirstResponder()
        mapView.removeAnnotations(mapView.annotations)
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler({(response: MKLocalSearchResponse?, error: NSError?) in
            if error != nil {
                let msg: String = "Error occured in search: \(error!.localizedDescription)"
                print(msg)
                let alertController = UIAlertController(title: "Search Error", message: msg, preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "Ok", style: .Cancel, handler: {action in})
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else if response!.mapItems.count == 0 {
                let msg = "No matches found"
                print(msg)
                let alertController = UIAlertController(title: "Search Error", message: msg, preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "Ok", style: .Cancel, handler: {action in})
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                self.saveButton.enabled = true
                print("Matches found")
                let firstResponse = response!.mapItems[0]
                //print("Name = \(firstResponse)")
                let annotation = MKPointAnnotation()
                annotation.coordinate = firstResponse.placemark.coordinate
                annotation.title = self.taskEntity.name
                self.locationName = searchBar.text
                self.location = annotation
                self.mapView.addAnnotation(annotation)
                self.setMapZoom(annotation)
            }
        })
        
    }
    
    
    
    func setMapZoom (annotation: MKPointAnnotation) -> () {
        let altitudeDelta: CLLocationDegrees = 0.5
        let longitudeDelta: CLLocationDegrees = 0.5
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(altitudeDelta, longitudeDelta)
        
        let region: MKCoordinateRegion = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        let buttonPressed = sender as! UIBarButtonItem
        if buttonPressed == saveButton {
            print("navigating from search and user wants to save annotation")
            taskEntity.locationLatitude = location!.coordinate.latitude
            taskEntity.locationLongitude = location!.coordinate.longitude
            taskEntity.locationName = locationName!
            bucket.saveEntities()
            self.delegate?.updateLocationMap(self.taskEntity)
        }
       
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
