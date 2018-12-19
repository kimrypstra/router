//
//  CoreDataManager.swift
//  Router
//
//  Created by Kim Rypstra on 10/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    func loadRoute(name: String) -> Route? {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Route")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                for data in result as! [NSManagedObject] {
                    print(data)
                    if data.value(forKey: "name") as! String == name {
                        return data as! Route
                    } else {
                        return nil
                    }
                }
            } else {
                return createNewRoute(name: name)
                
            }
            
        } catch {
            print("Load failed")
            return nil
        }
        
        return nil
    }
    
    func loadAllRoutes() -> [Route]? {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Route")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            return result as! [Route]
            
        } catch {
            print("Load failed")
            return nil
        }
        
        return nil
    }
    
    private func createNewRoute(name: String) -> Route? {
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Route", in: context)
        let newRoute = NSManagedObject(entity: entity!, insertInto: context)
        newRoute.setValue(name, forKey: "name")
        newRoute.setValue(Date(), forKey: "date")
        
        do {
            try context.save()
            return loadRoute(name: name)
        } catch {
            print("Failed")
            return nil
        }
    }
    
    func newRouteWithWaypoints(waypoints: [Waypoint], name: String, keep: Bool) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let routeEntity = NSEntityDescription.entity(forEntityName: "Route", in: context)
        let newRoute: Route = NSManagedObject(entity: routeEntity!, insertInto: context) as! Route
        newRoute.setValue(name, forKey: "name")
        newRoute.setValue(keep, forKey: "keep")
        //newRoute.addToWaypoints(NSSet(array: waypoints))
        newRoute.addToWaypoints(NSOrderedSet(array: waypoints))
        do {
            try context.save()
        } catch let error {
            print("Error saving SPB: \(error.localizedDescription)")
        }
    }
    
    func addWaypoint(lat: Double, long: Double, name: String, type: Type, keep: Bool) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let waypointEntity = NSEntityDescription.entity(forEntityName: "Waypoint", in: context)
        let newWaypoint: Waypoint = NSManagedObject(entity: waypointEntity!, insertInto: context) as! Waypoint
        newWaypoint.setValue(lat, forKey: "lat")
        newWaypoint.setValue(long, forKey: "long")
        newWaypoint.setValue(name, forKey: "name")
        newWaypoint.setValue(type.rawValue, forKey: "type")
        newWaypoint.setValue(keep, forKey: "keep")
        newWaypoint.setValue(Date(), forKey: "date")
        do {
            try context.save()
        } catch let error {
            print("Error saving SPB: \(error.localizedDescription)")
        }
    }
    
    func loadAllWaypoints() -> [Waypoint] {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Waypoint")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            return result as! [Waypoint]
            
        } catch {
            print("Load failed")
            return []
        }
    }
    
    func addWaypointToRoute(name: String, lat: String, long: String, major: Bool, position: Int16) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        var route: Route? = loadRoute(name: name)

        if route == nil {
            // Create a new route
            let newRoute = createNewRoute(name: name)
            route = newRoute
        }

        let entity = NSEntityDescription.entity(forEntityName: "Waypoint", in: context)
        let newWaypoint = NSManagedObject(entity: entity!, insertInto: context)
        newWaypoint.setValue(lat, forKey: "lat")
        newWaypoint.setValue(long, forKey: "long")
        newWaypoint.setValue(major, forKey: "major")
        newWaypoint.setValue(position, forKey: "position")

        route!.addToWaypoints(newWaypoint as! Waypoint)

        do {
            try context.save()
        } catch {
            print("Failed save")
        }
    }
    
}
