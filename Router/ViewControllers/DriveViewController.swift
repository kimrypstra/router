//
//  DriveViewController.swift
//  Router
//
//  Created by Kim Rypstra on 15/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DriveViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {

    var route: Route! // A list of Waypoint objects
    var mkRoutes: [MKRoute] = []
    let locMan = CLLocationManager()
    let routeMan = RouteManager()
    var currentSubroute = 0 // The current MKRoute
    var currentStep = 0 // The current MKRoute.Step
    var stepDistanceCovered: CLLocationDistance = 0 // The distance covered on the current step
    var stepThreshold: CLLocationDistance = 10
    var recog = UILongPressGestureRecognizer()
    
    var locationA: CLLocation?
    var locationB: CLLocation?
    
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        recog = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressOnMap(_:)))
        mapView.addGestureRecognizer(recog)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Loaded with route named: \(route.name)")
        // Figure out the route
        
        let group = DispatchGroup()
        group.enter()
        routeMan.getRoutes(waypoints: Array(route!.waypoints!) as! [Waypoint])  { (routes) in
            for index in routes.keys.sorted() {
                
                let route = routes[index]
                self.mkRoutes.append(route!)
                self.mapView.addOverlay(route!.polyline)
                print("Added route overlay...")
                for step in route!.steps {
                    let instruction = step.instructions
                    print(instruction)
                }
                
            }
            self.mapView.setVisibleMapRect(routes[1]!.polyline.boundingMapRect, animated: true)
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.locMan.delegate = self
            self.locMan.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            //self.locMan.startUpdatingLocation()
            self.changeCurrentSubroute(to: 0)
            self.changeCurrentStep(toStep: 1)
        }
    }
    
    @objc func didLongPressOnMap(_ sender: UILongPressGestureRecognizer) {
        recog.isEnabled = false
        // remove all previous annotations
        mapView.removeAnnotations(mapView.annotations)
        // convert the CGPoint to lat/long
        let coord = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
        updatedLocation(location: CLLocation(latitude: coord.latitude, longitude: coord.longitude))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        recog.isEnabled = true
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        // Skip to the next MKRoute - ie, currentSubroute += 1 and all the associated stuff
        changeCurrentStep(toStep: currentStep + 1)
    }
    
    @IBAction func previousButton(_ sender: UIButton) {
        // Skip to the previous MKRoute - ie, currentSubroute -= 1 and all the associated stuff
        changeCurrentStep(toStep: currentStep - 1)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue.withAlphaComponent(0.5)
        return renderer
    }
    
    
    var stepProgress = 0
    var previousDistance: CLLocationDistance = 0
    var lastCoordinate: CLLocation?
    var stepTotalDist: CLLocationDistance = 0
    
    // --- previousDistance -- lastCoordinate --- currentLocation
    // 
    func updatedLocation(location: CLLocation) {
        
        if lastCoordinate == nil {
            lastCoordinate = location
        } else {
            // Check that we are moving away from the last coordinate
            //
        }
        
        
        
        // If the remaining distance is less than some amount, move on to the next step
//        if stepRemainingDistance < stepTotalDistance {
//            // Update the steps
//            changeCurrentStep(toStep: currentStep + 1)
//        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else {return}
        updatedLocation(location: currentLocation)
    }
    
    func changeCurrentStep(toStep: Int) {
        // set stepDistanceCovered to 0
        let stepTotalCount = mkRoutes[currentSubroute].steps.count
        print("Moving to step \(toStep) of \(stepTotalCount)")
        
        if toStep > mkRoutes[currentSubroute].steps.count - 1 {
            currentSubroute += 1
            currentStep = 0
            changeCurrentSubroute(to: currentSubroute)
            return
        } else {
            // Reset the counters
            stepProgress = 0
            stepTotalDist = mkRoutes[currentSubroute].steps[currentStep].distance
            distanceLabel.text = ""
            
            // get the step
            currentStep = toStep
            
            let step = mkRoutes[currentSubroute].steps[currentStep]
            
            // Process the instruction to display the correct image
            /*
             - Possible instructions
             - Turn left
             - Turn right
             - At the roundabout, take the x exit
             - Arrive
             - Take exit
             - Keep left
             - Keep right
             - Bear left
             - Bear right
             -
             
             */
            
            let instruction = step.instructions
            let instructionTuple = processInstruction(instruction: instruction)
            imageView.image = UIImage(named: instructionTuple.manouver.rawValue)
            streetLabel.text = instructionTuple.street
        }

        
        
    }
    
    func changeCurrentSubroute(to: Int) {
        
    }
    
    func processInstruction(instruction: String) -> (manouver: Manouver, street: String, instruction: String) {
        print("Processing instruction: \(instruction)")
        var manouver: Manouver!
        for type in Manouver.array {
            if instruction.contains(type.rawValue) {
                manouver = type
                break
            } else {
                manouver = Manouver.Unknown
            }
        }
        
        // split by " "
        let split = instruction.split(separator: Character(" "))
        let caps = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        var street: [String] = []
        // work backwards through array
        for word in split.reversed() {
            let string = String(word)
            if caps.contains(String(string.characters.first!)) {
                // it's capitalised
                street.insert(String(word), at: 0)
            } else {
                break
            }
        }
        
        let streetString = street.joined(separator: " ")
        print("Current manouver: \(manouver.rawValue); \(streetString)")
        return (manouver: manouver, street: streetString, instruction: instruction)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
