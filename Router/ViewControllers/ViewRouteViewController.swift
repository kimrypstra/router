//
//  ViewRouteViewController.swift
//  Router
//
//  Created by Kim Rypstra on 14/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import UIKit
import MapKit
import CoreData


let baseCoordinates = CLLocationCoordinate2D(latitude: -31.8568, longitude: 115.9128)

extension Waypoint {
    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
    }
}

class ViewRouteViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var waypoints: [Waypoint]!
    var routeMan = RouteManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getRoutes(waypoints: waypoints)
    }
    
    func getRoutes(waypoints: [Waypoint]) {
        routeMan.getRoutes(waypoints: waypoints) { (routes) in
            for index in routes.keys.sorted() {
                let route = routes[index]
                self.mapView.addOverlay(route!.polyline)
                print("Added route overlay...")
                for step in route!.steps {
                    print(step.instructions)
                }
            }
            self.mapView.setVisibleMapRect(routes[1]!.polyline.boundingMapRect, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue.withAlphaComponent(0.5)
        return renderer
    }
    
    func insertWaypoint(first: Waypoint, second: Waypoint) {
        // Insert a waypoint (no majors, just the plain ol' minor waypoints) between two waypoints
        // Get two new routes, first > new and new > second
        // Add them into the main route
    }
    
    func displayRoutePolyline() {
        // Draw the route on the map
        // Also draw waypoints
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
