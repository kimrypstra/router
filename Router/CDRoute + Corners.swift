//
//  CDRoute + Corners.swift
//  Router
//
//  Created by Kim Rypstra on 22/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import Foundation
import CoreLocation

extension CDRoute {
    func southWest() -> CLLocationCoordinate2D {
        var southmostLat: CLLocationDegrees = 0
        var westmostLong: CLLocationDegrees = 179.99
        var waypoints = self.waypoints!.array as! [CDWaypoint]
        for waypoint in waypoints {
            let coord = waypoint.coordinate()
            if coord.latitude * -1 > southmostLat {
                southmostLat = coord.latitude
            }
            if coord.longitude < westmostLong {
                westmostLong = coord.longitude
            }
            
        }
        print("W: \(westmostLong) S: \(southmostLat)")
        return CLLocationCoordinate2D(latitude: southmostLat, longitude: westmostLong)
    }
    
    func northEast() -> CLLocationCoordinate2D {
        var northmostLat: CLLocationDegrees = 89.99
        var eastmostLong: CLLocationDegrees = 0
        var waypoints = self.waypoints!.array as! [CDWaypoint]
        for waypoint in waypoints {
            let coord = waypoint.coordinate()
            if coord.latitude < northmostLat {
                northmostLat = coord.latitude
            }
            if coord.longitude > eastmostLong {
                eastmostLong = coord.longitude
            }
        }
        print("N: \(northmostLat) E: \(eastmostLong)")
        return CLLocationCoordinate2D(latitude: northmostLat, longitude: eastmostLong)
    }
}
