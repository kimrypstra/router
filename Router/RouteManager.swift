//
//  RouteManager.swift
//  Router
//
//  Created by Kim Rypstra on 15/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class RouteManager {
    
    func getRoutes(waypoints: [CDWaypoint], completion: @escaping ([Int: MKRoute]) -> ()) {
        getRoutesBetweenWaypoints(waypoints: waypoints) { (routes) in
            completion(routes)
        }
    }
    
    private func getRoutesBetweenWaypoints(waypoints: [CDWaypoint], completion: @escaping ([Int: MKRoute]) -> ()) {
        var routeDict: [Int : MKRoute] = [:]
        // Tuple might be better?
        // [destIndex : routeToDest]
        // [2 : route] is the first item
        
        let group = DispatchGroup()
        
        // Call getRoute() between each waypoint
        for (index, waypoint) in waypoints.enumerated() {
            group.enter()
            print("Entered group")
            let destIndex = index + 1
            if waypoints.endIndex > destIndex {
                // Get the route and append it
                let start = waypoint
                let finish = waypoints[destIndex]
                getRoute(start: start.coordinate(), finish: finish.coordinate()) { (route) in
                    
                    routeDict[destIndex] = route
                    group.leave()
                    print("Left group")
                }
            } else {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Assemble the route
            completion(routeDict)
        }
    }
    
    private func getRoute(start: CLLocationCoordinate2D, finish: CLLocationCoordinate2D, completion: @escaping (MKRoute) -> ()) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: finish))
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        print("Getting route...")
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard error == nil && response != nil else {print("Error: \(error?.localizedDescription)"); return}
            guard let route = response?.routes.first else {print("No route"); return}
            print("Received route...")
            completion(route)
        }
    }
}
