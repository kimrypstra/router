//
//  ViewController.swift
//  Router
//
//  Created by Kim Rypstra on 10/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//



/*
Requirements
 - Direct user between multiple waypoints
 - Record a trip and save as waypoints
 - Manually input waypoints
 - Verbally direct turn by turn
 - Detect when user is at a waypoint and present a 'next' button
 - Allow user to skip waypoints
 - Reroute to current waypoint if user strays from the route, then resume the saved route 
 
*/



import UIKit
import CoreLocation

class MainMenuViewController: UITableViewController, CLLocationManagerDelegate {

    var locMan: CLLocationManager!
    
    var cdMan = CoreDataManager()
    
    @IBOutlet weak var drivePreMadeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locMan = CLLocationManager()
        
//        let parser = Parser()
//        let csv = parser.readCSV(name: "SPBs")
//        parser.modifyBasedOnID(csv: csv!)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locMan = CLLocationManager()
        locMan.requestAlwaysAuthorization()
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            locMan.startUpdatingLocation()
            locMan.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        default:
            locMan.requestAlwaysAuthorization()
        }
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "temporaryRoute":
            let IVC = segue.destination as! InputAddressViewController
            IVC.addingForTemporaryRoute = true
            IVC.editingMode = .Add
        case "inputWaypoint":
            let IVC = segue.destination as! InputAddressViewController
            IVC.addingForTemporaryRoute = false
            IVC.editingMode = .Add
        case "newRoute":
            print("Going to new route")
            let IVC = segue.destination as! NewRouteViewController
            IVC.mode = .Add
        case "driveRoute":
            print("Going to drive route")
        default:
            print("Error: Segue unknown")
        }
    }


}

