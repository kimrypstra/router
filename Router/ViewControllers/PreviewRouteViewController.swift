//
//  PreviewRouteViewController.swift
//  Router
//
//  Created by Kim Rypstra on 22/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import UIKit
import Mapbox
import MapboxNavigationNative
import MapboxNavigation
import MapboxCoreNavigation
import MapboxDirections
import MapboxSpeech
import MapboxMobileEvents
import CoreLocation

enum ArrivalMode {
    case Normal
    case StartingNewSubroute
    case Finished
}

extension Waypoint {
    override open var description: String {
        get {
            return self.name!
        }
    }
}

class PreviewRouteViewController: UIViewController, MGLMapViewDelegate, URLSessionDelegate, NavigationViewControllerDelegate, ArrivalViewControllerDelegate {

    @IBOutlet weak var mapView: MGLMapView!
    let locMan = CLLocationManager()
    var route: CDRoute!
    var directionsRoutes: [Route]?
    var currentSubroute = 0
    var currentWaypointIndex = 0
    var orderedRoute: [CDWaypoint] = []
    var multipleRoutesAllowed = false
    var navigationVC: NavigationViewController!
    var arrival: ArrivalViewController?
    var arrivalMode: ArrivalMode = .Normal
    @IBOutlet weak var simSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self 
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        locMan.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("**Challenge: \(challenge)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bounds = MGLCoordinateBounds(sw: route.southWest(), ne: route.northEast())
        let insets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        let routeCam = mapView.cameraThatFitsCoordinateBounds(bounds, edgePadding: insets)
        
        print("**Loaded route: ")
        let waypoints = route.waypoints?.array as! [CDWaypoint]
        for waypoint in waypoints {
            print(waypoint.name)
        }
        
        mapView.setCamera(routeCam, animated: true)
        generatePins(waypoints: route.waypoints?.array as! [CDWaypoint])
        
        generateRoute(waypoints: route.waypoints?.array as! [CDWaypoint]) { (routes) in
            //
            guard routes.count > 0 else {
                print("**No routes?")
                return
            }
            
            //var routesArray: [Route?] = Array(repeating: nil, count: routes.count)
            
            for (index, subroute) in routes.enumerated() {
                print("**Subroute \(index)")
                for mbwaypoint in subroute.routeOptions.waypoints {
                    print(mbwaypoint.name!)
                }
            }
            
            self.directionsRoutes = routes

            //self.directionsRoute = route
            
            self.drawRoutes(routes: routes)
            
        }
    }

    
    @IBAction func tappedDriveButton(_ sender: UIBarButtonItem) {
        print("**Tapped drive button")
        guard directionsRoutes != nil else {return}
        if orderedRoute.count == 0 {
            print("**Starting route in default order")
            // If you have selected none, just drive the route in that order
            navigationVC = NavigationViewController(for: directionsRoutes![0])
            if simSwitch.isOn {
                navigationVC.navigationService.simulationMode = .always
                navigationVC.navigationService.simulationSpeedMultiplier = 3
            }
            // Add the 'next waypoint' control'
            let but = FloatingButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            but.cornerRadius = 25
            //let button = UIButton(type: .custom)
            let image = UIImage(named: "next")!
            but.setImage(image, for: .normal)
            //shadowOpacity = 0.1; shadowRadius = 4; shadowOffset = CGSize (0 0)
            but.layer.shadowOpacity = 0.1
            but.layer.shadowRadius = 4
            but.layer.shadowOffset = CGSize(width: 0, height: 0)
            but.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
            //button.tintColor = .blue
            //button.frame = CGRect(origin: navigationVC.view.center, size: CGSize(width: 100, height: 50))
            //navigationVC.view.addSubview(button)
            
            //button.center = navigationVC.view.center
            let stack = navigationVC.view.subviews[0].subviews[2] as! UIStackView
            stack.addArrangedSubview(but)
            navigationVC.delegate = self
            //present(navigationVC, animated: true, completion: nil)
            navigationController?.present(navigationVC, animated: true, completion: nil)
        } else if orderedRoute.count == route.waypoints?.count {
            print("**Starting route in altered order")
            // Only if you have selected all of the routes, regenerate the route in the order of orderedRoute
            navigationVC = NavigationViewController(for: directionsRoutes![0])
            if simSwitch.isOn {
                navigationVC.navigationService.simulationMode = .always
                navigationVC.navigationService.simulationSpeedMultiplier = 3
            }
            // Add the 'next waypoint' control'
            let but = FloatingButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            but.cornerRadius = 25
            //let button = UIButton(type: .custom)
            let image = UIImage(named: "next")!
            but.setImage(image, for: .normal)
            //shadowOpacity = 0.1; shadowRadius = 4; shadowOffset = CGSize (0 0)
            but.layer.shadowOpacity = 0.1
            but.layer.shadowRadius = 4
            but.layer.shadowOffset = CGSize(width: 0, height: 0)
            but.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
            navigationVC.delegate = self 
            //present(navigationVC, animated: true, completion: nil)
            navigationController?.present(navigationVC, animated: true, completion: nil)
        } else {
            print("**Can't start route, not all waypoints have been ordered")
            // You've started reordering, but haven't finished. Do nothing!
        }
        
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didRerouteAlong route: Route) {
        print("**reroute")
    }
    
    @objc func didTapSkipButton() {
        _ = navigationViewController(navigationVC, didArriveAt: navigationVC.navigationService.routeProgress.currentLeg.destination)
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
        arrival = self.storyboard?.instantiateViewController(withIdentifier: "ArrivalViewController") as! ArrivalViewController
        let nextWaypoint = navigationViewController.navigationService.routeProgress.upcomingLeg?.destination
        var nextWaypointCD: CDWaypoint?
        
        if nextWaypoint == nil {
            if currentSubroute < directionsRoutes!.count - 1 {
                // There is another subroute to follow
                print("**Starting new subroute")
                arrivalMode = .StartingNewSubroute
                let nextWaypointName = directionsRoutes![currentSubroute + 1].routeOptions.waypoints[1].name! // Remember, the first waypoint of the next subroute is the same as the last in it's previous subroute
                nextWaypointCD = (route.waypoints?.array as! [CDWaypoint]).filter({$0.name == nextWaypointName}).first
            } else {
                print("**Finished")
                arrivalMode = .Finished
                arrival?.removeProceedButton = true 
                arrival?.removeNextField = true
            }
        } else {
            print("**Normal")
            arrivalMode = .Normal
            nextWaypointCD = (route.waypoints?.array as! [CDWaypoint]).filter({$0.name == nextWaypoint?.name}).first
        }
        
        // Get the next waypoint directly from the nav controller
        // If there is no next waypoint, then increment the subroute and start a new route
        
        // Return false here - we are handling the advancement manually
        
        arrival!.delegate = self
        arrival!.arrivedName = waypoint.name!
        arrival!.nextName = nextWaypointCD?.name
        let type = String(describing: nextWaypointCD?.type)
        
        if let image = UIImage(named: "\(String(describing: type))") {
            arrival!.image = image
        }
        
        
//
//        if currentWaypointIndex >= lastWaypointIndex {
//            // We've arrived at the last waypoint in this subroute
//            // Check if there's another subroute
//            if currentSubroute >= directionsRoutes!.count - 1 {
//                // We are on the last subroute, and we just finished it - the route is over
//                // Leave 'nextName' blank/remove the 'next' field altogether
//                print("**\(navigationVC.navigationService.routeProgress.legIndex) of \(navigationVC.route.legs.count - 1) - Deemed .Finished")
//                print("**\(directionsRoutes![currentSubroute].routeOptions.waypoints.prefix(upTo: currentWaypointIndex)) -- \(directionsRoutes![currentSubroute].routeOptions.waypoints.suffix(from: currentWaypointIndex))")
//                arrivalMode = .Finished
//                arrival!.removeNextField()
//                arrival!.removeProceedButton()
//            } else {
//                // There are more subroutes to follow
//                // Get the name of the first waypoint of the next subroute
//                arrival!.nextName = directionsRoutes![currentSubroute + 1].routeOptions.waypoints[0].name!
//                print("**\(navigationVC.navigationService.routeProgress.legIndex) of \(navigationVC.route.legs.count - 1) - Deemed .StartingNewSubroute")
//                print("**\(directionsRoutes![currentSubroute].routeOptions.waypoints.prefix(upTo: currentWaypointIndex)) -- \(directionsRoutes![currentSubroute].routeOptions.waypoints.suffix(from: currentWaypointIndex))")
//                arrivalMode = .StartingNewSubroute
//            }
//        } else {
//            // There are more waypoints in this subroute
//            // Set nextName to the name of the next waypoint in this subroute
//            arrivalMode = .Normal
//            print("**\(navigationVC.navigationService.routeProgress.legIndex) of \(navigationVC.route.legs.count - 1) - Deemed .Normal")
//            print("**\(directionsRoutes![currentSubroute].routeOptions.waypoints.prefix(upTo: currentWaypointIndex)) -- \(directionsRoutes![currentSubroute].routeOptions.waypoints.suffix(from: currentWaypointIndex))")
//            arrival!.nextName = directionsRoutes![currentSubroute].routeOptions.waypoints[currentWaypointIndex + 1].name!
//        }

        navigationViewController.present(arrival!, animated: true, completion: nil)
        return false // Yes, return false
    }
    
    @objc func didTapProceed() {
        switch arrivalMode {
        case .Normal:
            currentWaypointIndex += 1
            
            navigationVC.navigationService.routeProgress.legIndex += 1
            arrival?.dismiss(animated: true, completion: nil)
            navigationVC.navigationService.start()
        case .StartingNewSubroute:
            
            currentSubroute += 1
            print("**Starting subroute \(currentSubroute)")
            currentWaypointIndex = 0
            navigationVC.route = directionsRoutes![currentSubroute]
            arrival?.dismiss(animated: true, completion: nil)
            navigationVC.navigationService.start()
            print("**Updated subroute...")
        case .Finished:
            print("**This should not be reached, since the proceed button should have been removed")
            arrival?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func didTapEndRoute() {
        navigationVC.navigationService.stop()
        self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2].dismiss(animated: true, completion: {
            print("Done?")
        })
        self.navigationController?.popToRootViewController(animated: true)
        navigationVC = nil
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        print("**Selected WP: \(String(describing: annotation.title!))")
        guard let waypoint = (route.waypoints?.array as! [CDWaypoint]).filter({$0.name == annotation.title}).first else {
            print("**Couldn't find a waypoint that matches the name?")
            return
        }
        orderedRoute.append(waypoint)
        generateRoute(waypoints: orderedRoute) { (routes) in
            //
            guard routes.count > 0 else {
                print("**No routes?")
                return
            }
            
            for (index, subroute) in routes.enumerated() {
                print("**Subroute \(index)")
                for mbwaypoint in subroute.routeOptions.waypoints {
                    print(mbwaypoint.name!)
                }
            }
            
            self.directionsRoutes = routes
            
            self.drawRoutes(routes: routes)
            
        }
        
//        mapView.removeAnnotations(mapView.annotations!)
//        generatePins(waypoints: route.waypoints?.array as! [CDWaypoint])
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        if orderedRoute.count == 0 {
            return .green
        } else {
            if orderedRoute.filter({$0.name == annotation.title}).count != 0 {
                return .green
            } else {
                return .red
            }
        }
    }
    
//    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
//        //
//    }
    
    func generatePins(waypoints: [CDWaypoint]) {
        var annos: [MGLPointAnnotation] = []
        for waypoint in waypoints {
            let anno = MGLPointAnnotation()
            anno.coordinate = waypoint.coordinate()
            anno.title = waypoint.name
            annos.append(anno)
            
        }
        
        mapView.addAnnotations(annos)
    }
    
    func generateRoute(waypoints: [CDWaypoint], completion: @escaping ([Route]) -> ()) {
        print("**Generating route between \(waypoints.count) waypoints...")
        let maxWaypointsPerLeg = 10
        
        if waypoints.count <= 1 {
            print("**Multiple waypoints required")
            return
        }
        
        let cdMan = CoreDataManager()
        var waypointsIncludingCurrentPosition = waypoints
        let location = locMan.location?.coordinate
        cdMan.createTemporaryWaypoint(lat: location!.latitude, long: location!.longitude, name: "Current Position", type: .Waypoint, keep: false) { (waypoint) in
            waypointsIncludingCurrentPosition.insert(waypoint, at: 0)
        }
        
        
        print("** Waypoints incl. start: \(waypointsIncludingCurrentPosition.count)")
        var coordinates: [[Waypoint]] = []
        var subroute = 0
        for (index, waypoint) in waypointsIncludingCurrentPosition.enumerated() {
            let coord = Waypoint(coordinate: waypoint.coordinate(), coordinateAccuracy: -1, name: waypoint.name)
            if Type(rawValue: Int(waypoint.type)) == .SPB || Type(rawValue: Int(waypoint.type)) == .Pedestal {
                coord.allowsArrivingOnOppositeSide = false
            }
            
            
            print("**SR: \(subroute)")
            
            if coordinates.count == 0 {
                // This is the first entry overall
                coordinates.append([coord])
                continue
            }
            
            if coordinates.count - 1 < subroute {
                // This is the first entry of a new subroute
                // Get the last waypoint from the previous subroute
                let prevSubrouteLastWaypoint = coordinates[subroute - 1].last!
                // Add it to a new array and append it to the main array
                coordinates.append([prevSubrouteLastWaypoint])
            }
            coordinates[subroute].append(coord)
            print("**SR Count: \(coordinates[subroute].count)")
            if coordinates[subroute].count == maxWaypointsPerLeg {
                subroute += 1
                print("**SR Incremented")
            }
        }
        
        var receivedRoutes: [Route?] = Array(repeating: nil, count: coordinates.count)
        let group = DispatchGroup()
        
        for (index, subroute) in coordinates.enumerated() {
            group.enter()
            let options = NavigationRouteOptions(waypoints: coordinates[index], profileIdentifier: .automobile)
            options.allowsUTurnAtWaypoint = true
            options.includesAlternativeRoutes = false
            options.routeShapeResolution = .full
            print("**About to send request to mapbox for \(subroute.count) waypoints...")
            _ = Directions.shared.calculate(options, completionHandler: { (coordinates, routes, error) in
                print("**Received response...")
                guard error == nil else {
                    print("**Error generating route: \(error?.localizedDescription)")
                    return
                }
                
                receivedRoutes[index] = routes!.first!
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            completion(receivedRoutes as! [Route])
        }
        
        
    }
    
    func drawRoutes(routes: [Route]) {
        print("**Drawing route...")
        
        //var routeCoordinates
        var routeCoordinates: [CLLocationCoordinate2D] = []
        for subroute in routes {
            routeCoordinates += subroute.coordinates!
        }
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))
        
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            print("**There's already a source")
            // If there's already a layer there, just set it to the polyline
            source.shape = polyline
        } else {
            print("**Creating a new source")
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: UIColor.blue)
            lineStyle.lineWidth = NSExpression(forConstantValue: 4.0)
            mapView.style!.addSource(source)
            mapView.style!.addLayer(lineStyle)
            //'MGLConstantStyleValue' is unavailable: Use +[NSExpression expressionForConstantValue:] instead.
        }
        
        
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
