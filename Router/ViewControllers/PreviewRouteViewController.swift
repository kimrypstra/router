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

class PreviewRouteViewController: UIViewController, MGLMapViewDelegate {

    @IBOutlet weak var mapView: MGLMapView!
    var route: CDRoute!
    var directionsRoute: Route?
    var orderedRoute: [CDWaypoint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self 
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bounds = MGLCoordinateBounds(sw: route.southWest(), ne: route.northEast())
        let insets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        let routeCam = mapView.cameraThatFitsCoordinateBounds(bounds, edgePadding: insets)
        mapView.setCamera(routeCam, animated: true)
        generatePins(waypoints: route.waypoints?.array as! [CDWaypoint])
        
        generateRoute(waypoints: route.waypoints?.array as! [CDWaypoint]) { (route, error) in
            //
            if error != nil {
                print("Error generating route: \(error)")
            }
        }
    }
    
    
    
    @IBAction func tappedDriveButton(_ sender: UIBarButtonItem) {
        print("Tapped drive button")
        if orderedRoute.count == 0 {
            print("Starting route in default order")
            // If you have selected none, just drive the route in that order
            let navigationVC = NavigationViewController(for: directionsRoute!)
            navigationVC.navigationService.simulationMode = .always
            navigationVC.navigationService.simulationSpeedMultiplier = 3
            
            present(navigationVC, animated: true, completion: nil)
        } else if orderedRoute.count == route.waypoints?.count {
            print("Starting route in altered order")
            // Only if you have selected all of the routes, regenerate the route in the order of orderedRoute
            let navigationVC = NavigationViewController(for: directionsRoute!)
            present(navigationVC, animated: true, completion: nil)
        } else {
            print("Can't start route, not all waypoints have been ordered")
            // You've started reordering, but haven't finished. Do nothing!
        }
        
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        print("Selected WP: \(annotation.title)")
        guard let waypoint = (route.waypoints?.array as! [CDWaypoint]).filter({$0.name == annotation.title}).first else {
            print("Couldn't find a waypoint that matches the name?")
            return
        }
        orderedRoute.append(waypoint)
        generateRoute(waypoints: orderedRoute) { (route, error) in
            if error != nil {
                print("Error generating route: \(error)")
            }
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
    
    func generateRoute(waypoints: [CDWaypoint], completion: @escaping (Route, Error) -> ()) {
        print("Generating route...")
        guard waypoints.count <= 25 else {
            print("Error! Too many waypoints for current implementation!")
            return
        }
        
        var coordinates: [Waypoint] = []
        
        for waypoint in waypoints {
            let coord = Waypoint(coordinate: waypoint.coordinate(), coordinateAccuracy: -1, name: waypoint.name)
            coordinates.append(coord)
        }
        
        let options = NavigationRouteOptions(waypoints: coordinates, profileIdentifier: .automobile)
        _ = Directions.shared.calculate(options, completionHandler: { (waypoints, routes, error) in
            guard error == nil else {
                print("Error generating route: \(error?.localizedDescription)")
                return
            }
            self.directionsRoute = routes?.first
            if self.directionsRoute != nil {
                self.drawRoute(route: self.directionsRoute!)
            }
            
        })
    }
    
    func drawRoute(route: Route) {
        print("Drawing route...")
        guard route.coordinateCount > 0 else {
            return
        }
        var routeCoordinates = route.coordinates!
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            print("There's already a source")
            // If there's already a layer there, just set it to the polyline
            source.shape = polyline
        } else {
            print("Creating a new source")
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
