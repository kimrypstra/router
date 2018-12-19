//
//  ViewController.swift
//  Router
//
//  Created by Kim Rypstra on 10/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class InputCoordinatesViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate  {

    @IBOutlet weak var keepSwitch: UISwitch!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var spbSeg: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameField: UITextField!
    
    var locMan = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locMan.desiredAccuracy = kCLLocationAccuracyBest
        locMan.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func currentLoc(_ sender: UIButton) {
        let loc = locMan.location
        latitudeField.text = "\(loc!.coordinate.latitude)"
        longitudeField.text = "\(loc!.coordinate.longitude)"
    }
    @IBAction func segDidChange(_ sender: UISegmentedControl) {
        if spbSeg.selectedSegmentIndex == 1 {
            nameField.placeholder = "Name"
        } else {
            nameField.placeholder = "Name (optional)"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case latitudeField:
            longitudeField.becomeFirstResponder()
        case longitudeField:
            longitudeField.resignFirstResponder()
            // Scroll the map
            guard let latitude = Double(latitudeField.text!), let longitude = Double(longitudeField.text!) else {
                print("Error casting text field input as CLLocationDegrees")
                return false
            }
            mapView.setCenter(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), animated: true)
            mapView.camera.altitude = 100
            
        default:
            print("Error: Unknown text field")
        }
        return true
        
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        // Call addWaypoint from cdMan
        if spbSeg.selectedSegmentIndex == 1 && nameField.text?.count == 0 {
            print("Name must be present for SPB")
            return
        }
        
        guard let latitude = Double(latitudeField.text!), let longitude = Double(longitudeField.text!) else {
            print("Error casting text field input as CLLocationDegrees")
            return
        }
        
        let cdMan = CoreDataManager()
        cdMan.addWaypoint(lat: latitude, long: longitude, name: nameField.text!, type: Type(rawValue: spbSeg.selectedSegmentIndex)!, keep: keepSwitch.isOn)
    }
    
    
    func checkTextFieldFormatting(text: String) -> Bool {
        // Make sure the text matches lat/long format
        // Fill this out a bit more later
        if text.split(separator: Character(".")).count == 2 {
            return true
        } else {
            return false
        }
    }
    
//    func addWaypointToRoute(name: String, latitude: String, longitude: String, major: Bool) {
//        let cdMan = CoreDataManager()
//        cdMan.addWaypointToRoute(name: name, lat: latitude, long: longitude, major: major, position: 1)
//
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
