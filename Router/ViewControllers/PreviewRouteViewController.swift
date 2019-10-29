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
    var shouldAllowDrive = true
    
    @IBOutlet weak var simSwitch: UISwitch!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var driveButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MGLMapView!
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self 
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        locMan.startUpdatingLocation()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if shouldAllowDrive == false {
            driveButton.isEnabled = false
        }
        spinner.isHidden = true
    }
    
//    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print("**Challenge: \(challenge)")
//    }
    
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
        generatePins(waypoints: route.waypoints?.array as! [CDWaypoint])

    }
    
    @IBAction func tappedDriveButton(_ sender: UIBarButtonItem) {
        print("**Tapped drive button")
        guard directionsRoutes != nil else {return}
        
        if orderedRoute.count == 0 {
            print("**Starting route in default order")
            // If you have selected none, just drive the route in that order
            //navigationVC = NavigationViewController(for: directionsRoutes![0])
            navigationVC = NavigationViewController(for: directionsRoutes![0], styles: [KimStyle()], navigationService: nil, voiceController: nil)
            if simSwitch.isOn {
                navigationVC.navigationService.simulationMode = .always
                navigationVC.navigationService.simulationSpeedMultiplier = 3
            }
            // Add the 'next waypoint' control'
            let but = FloatingButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            but.cornerRadius = 25
            //let button = UIButton(type: .custom)
            let image = UIImage(named: "next")?.withRenderingMode(.alwaysTemplate)
            but.setImage(image, for: .normal)
            //shadowOpacity = 0.1; shadowRadius = 4; shadowOffset = CGSize (0 0)
            but.layer.shadowOpacity = 0.1
            but.layer.shadowRadius = 4
            but.layer.shadowOffset = CGSize(width: 0, height: 0)
            but.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
            but.tintColor = .white
            but.frame.size = CGSize(width: 50, height: 50)
//            for view in navigationVC.view.subviews[0].subviews[0].subviews[0] {
//                print("\(view)")
//            }
            let stack = navigationVC.view.subviews[0].subviews[1] as! UIStackView
            stack.addArrangedSubview(but)
            let map = navigationVC.view.subviews[0].subviews[0].subviews[0]
            
            for con in map.constraints {
                print(con)
            }
            navigationVC.delegate = self
            
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
            let image = UIImage(named: "next")?.withRenderingMode(.alwaysTemplate)
            but.setImage(image, for: .normal)
            //shadowOpacity = 0.1; shadowRadius = 4; shadowOffset = CGSize (0 0)
            but.layer.shadowOpacity = 0.1
            but.layer.shadowRadius = 4
            but.layer.shadowOffset = CGSize(width: 0, height: 0)
            but.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
            but.tintColor = .white
            but.frame.size = CGSize(width: 50, height: 50)
            for view in navigationVC.view.subviews[0].subviews[1].subviews {
                print("\(view)")
            }
            let stack = navigationVC.view.subviews[0].subviews[1] as! UIStackView
            stack.addArrangedSubview(but)
            navigationVC.delegate = self 
            
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
                let nextWaypointName = directionsRoutes![currentSubroute + 1].routeOptions.waypoints[1].name! // Remember, the first waypoint of the next subroute is the same as the last in the previous subroute
                nextWaypointCD = (route.waypoints?.array as! [CDWaypoint]).filter({$0.name == nextWaypointName}).first
            } else {
                print("**Finished")
                arrivalMode = .Finished
                //arrival!.finished = true
            }
        } else {
            print("**Normal")
            arrivalMode = .Normal
            nextWaypointCD = (route.waypoints?.array as! [CDWaypoint]).filter({$0.name == nextWaypoint?.name}).first
        }
        
        if nextWaypointCD != nil {
            arrival?.image = UIImage(named: "\(nextWaypointCD!.type)")
            arrival?.nextName = nextWaypointCD?.name
            arrival?.delegate = self
        } else {
            arrival?.image = UIImage(named: "done")
            arrival?.nextName = "Finished!"
            arrival?.delegate = self
        }
        
        
        navigationVC.present(arrival!, animated: true, completion: nil)

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
            didTapEndRoute()
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
        spinner.startAnimating()
        spinner.isHidden = false
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
            self.spinner.isHidden = true
            self.spinner.stopAnimating()
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
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        let waypoints = route.waypoints!.array as! [CDWaypoint]
        let type = waypoints.filter {$0.name == annotation.title}.first!.type
        let image = UIImage(named: "\(type)")
        let scaled = UIImage(cgImage: image!.cgImage!, scale: 15, orientation: image!.imageOrientation)
        return MGLAnnotationImage(image: scaled, reuseIdentifier: "\(type)")
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
        for (_, waypoint) in waypointsIncludingCurrentPosition.enumerated() {
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

        for (_, subroute) in routes.enumerated() {
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
            lineStyle.lineColor = NSExpression(forConstantValue: UIColor.systemBlue)
            lineStyle.lineOpacity = NSExpression(forConstantValue: 0.8)
            lineStyle.lineWidth = NSExpression(forConstantValue: 10)
            lineStyle.lineJoin = NSExpression(forConstantValue: MGLLineJoin.round.rawValue)
            
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
