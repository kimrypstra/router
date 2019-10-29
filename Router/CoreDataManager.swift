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
    
    func checkIfNameAvailable(name: String) -> Bool {
        var flag = true
        if let routes = loadAllRoutes() {
            for route in routes {
                if route.name == name {
                    flag = false
                }
            }
        }
        return flag
    }
    
    func loadRoute(name: String) -> CDRoute? {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDRoute")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                for data in result as! [NSManagedObject] {
                    print(data)
                    if data.value(forKey: "name") as! String == name {
                        return data as! CDRoute
                    } else {
                        //return nil
                        // If this is uncommented it will just return after a single cycle if it's not the first one returned
                    }
                }
            } else {
                return createNewRoute(name: name).0
            }
            
        } catch {
            print("Load failed")
            return nil
        }
        
        return nil
    }
    
    func createTemporaryRoute(waypoints: [CDWaypoint], name: String, keep: Bool) -> CDRoute {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let routeEntity = NSEntityDescription.entity(forEntityName: "CDRoute", in: context)
        let newRoute: CDRoute = NSManagedObject(entity: routeEntity!, insertInto: context) as! CDRoute
        newRoute.setValue(name, forKey: "name")
        newRoute.setValue(keep, forKey: "keep")
        //newRoute.addToWaypoints(NSSet(array: waypoints))
        newRoute.addToWaypoints(NSOrderedSet(array: waypoints))
        return newRoute as! CDRoute
    }
    
    func addSPBFromFile(active: Bool, address: String, catchment: String, clearanceTime: String, colour: String, comment: String, finalDuty: String, finalDutyPoint: Int16, flag: String, hub: String, keep: Bool, keyNumber: String, labelDate: Date, labelInner: String, labelOuter: String, lat: Double, long: Double, name: String, nat_id: String, postcode: String, state: String, suburb: String, sundayClearance: Bool, sundayClearanceTime: String, type: Int16, wa_id: String, wcc: String) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let waypointEntity = NSEntityDescription.entity(forEntityName: "CDWaypoint", in: context)
        let newWaypoint: CDWaypoint = NSManagedObject(entity: waypointEntity!, insertInto: context) as! CDWaypoint
        newWaypoint.setValue(active, forKey: "active")
        newWaypoint.setValue(address, forKey: "address")
        newWaypoint.setValue(catchment, forKey: "catchment")
        newWaypoint.setValue(clearanceTime, forKey: "clearanceTime")
        newWaypoint.setValue(colour, forKey: "colour")
        newWaypoint.setValue(comment, forKey: "comment")
        newWaypoint.setValue(Date(), forKey: "date")
        newWaypoint.setValue(finalDuty, forKey: "finalDuty")
        newWaypoint.setValue(finalDutyPoint, forKey: "finalDutyPoint")
        newWaypoint.setValue(flag, forKey: "flag")
        newWaypoint.setValue(hub, forKey: "hub")
        newWaypoint.setValue(keep, forKey: "keep")
        newWaypoint.setValue(keyNumber, forKey: "keyNumber")
        newWaypoint.setValue(labelDate, forKey: "labelDate")
        newWaypoint.setValue(labelInner, forKey: "labelInner")
        newWaypoint.setValue(labelOuter, forKey: "labelOuter")
        newWaypoint.setValue(lat, forKey: "lat")
        newWaypoint.setValue(long, forKey: "long")
        newWaypoint.setValue(name, forKey: "name")
        newWaypoint.setValue(nat_id, forKey: "nat_id")
        newWaypoint.setValue(postcode, forKey: "postcode")
        newWaypoint.setValue(state, forKey: "state")
        newWaypoint.setValue(suburb, forKey: "suburb")
        newWaypoint.setValue(sundayClearance, forKey: "sunClearance")
        newWaypoint.setValue(sundayClearanceTime, forKey: "sunClearanceTime")
        newWaypoint.setValue(type, forKey: "type")
        newWaypoint.setValue(wa_id, forKey: "wa_id")
        newWaypoint.setValue(wcc, forKey: "wcc")
        
        do {
            try context.save()
            
        } catch let error {
            print("Error saving SPB: \(error.localizedDescription)")
            
        }
    }
    
    func createTemporaryWaypoint(lat: Double, long: Double, name: String, type: Type, keep: Bool, completion: @escaping (CDWaypoint) -> ()) {
        print("Temp")
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CDWaypoint", in: context)
        let waypoint = NSManagedObject(entity: entity!, insertInto: context)
        waypoint.setValue(lat, forKey: "lat")
        waypoint.setValue(long, forKey: "long")
        waypoint.setValue(name, forKey: "name")
        waypoint.setValue(type.rawValue, forKey: "type")
        waypoint.setValue(keep, forKey: "keep")
        waypoint.setValue(Date(), forKey: "date")
        
        completion(waypoint as! CDWaypoint)
    }
    
    func loadAllRoutes() -> [CDRoute]? {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDRoute")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            return result as! [CDRoute]
            
        } catch {
            print("Load failed")
            return nil
        }
        
        return nil
    }
    
    private func createNewRoute(name: String) -> (CDRoute?, String?) {
        if checkIfNameAvailable(name: name) == false {
            return (nil, "Name taken")
        }
        
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "CDRoute", in: context)
        let newRoute = NSManagedObject(entity: entity!, insertInto: context)
        newRoute.setValue(name, forKey: "name")
        newRoute.setValue(Date(), forKey: "date")
    
        do {
            try context.save()
            return (loadRoute(name: name), nil)
        } catch let error {
            print("Failed")
            return (nil, error.localizedDescription)
        }
    }
    
    func newRouteWithWaypoints(waypoints: [CDWaypoint], name: String, keep: Bool) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let routeEntity = NSEntityDescription.entity(forEntityName: "CDRoute", in: context)
        let newRoute: CDRoute = NSManagedObject(entity: routeEntity!, insertInto: context) as! CDRoute
        newRoute.setValue(name, forKey: "name")
        newRoute.setValue(keep, forKey: "keep")
        newRoute.setValue(Date(), forKey: "date")
        //newRoute.addToWaypoints(NSSet(array: waypoints))
        newRoute.addToWaypoints(NSOrderedSet(array: waypoints))
        do {
            try context.save()
        } catch let error {
            print("Error saving SPB: \(error.localizedDescription)")
        }
    }
    
    func addWaypoint(lat: Double, long: Double, name: String, type: Type, keep: Bool, completion: @escaping (Error?) -> ()) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let waypointEntity = NSEntityDescription.entity(forEntityName: "CDWaypoint", in: context)
        let newWaypoint: CDWaypoint = NSManagedObject(entity: waypointEntity!, insertInto: context) as! CDWaypoint
        newWaypoint.setValue(lat, forKey: "lat")
        newWaypoint.setValue(long, forKey: "long")
        newWaypoint.setValue(name, forKey: "name")
        newWaypoint.setValue(type.rawValue, forKey: "type")
        newWaypoint.setValue(keep, forKey: "keep")
        newWaypoint.setValue(Date(), forKey: "date")
        do {
            try context.save()
            completion(nil)
        } catch let error {
            print("Error saving SPB: \(error.localizedDescription)")
            completion(error)
        }
    }
    
    func loadAllWaypoints() -> [CDWaypoint] {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDWaypoint")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            return result as! [CDWaypoint]
            
        } catch {
            print("Load failed")
            return []
        }
    }
    
    func addWaypointToRoute(name: String, lat: String, long: String, major: Bool, position: Int16) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        var route: CDRoute? = loadRoute(name: name)

        if route == nil {
            // Create a new route
            let newRoute = createNewRoute(name: name)
            route = newRoute.0
        }

        let entity = NSEntityDescription.entity(forEntityName: "CDWaypoint", in: context)
        let newWaypoint = NSManagedObject(entity: entity!, insertInto: context)
        newWaypoint.setValue(lat, forKey: "lat")
        newWaypoint.setValue(long, forKey: "long")
        newWaypoint.setValue(major, forKey: "major")
        newWaypoint.setValue(position, forKey: "position")

        route!.addToWaypoints(newWaypoint as! CDWaypoint)
        route?.setValue(Date(), forKey: "date")
        
        do {
            try context.save()
        } catch {
            print("Failed save")
        }
    }
    
    func editWaypoint(id: NSManagedObjectID, active: Bool?, address: String?, catchment: String?, clearanceTime: String?, colour: String?, comment: String?, finalDuty: String?, finalDutyPoint: Int16?, flag: String?, hub: String?, keep: Bool?, keyNumber: String?, labelDate: Date?, labelInner: String?, labelOuter: String?, lat: Double?, long: Double?, name: String?, nat_id: String?, postcode: String?, state: String?, suburb: String?, sundayClearance: Bool?, sundayClearanceTime: String?, type: Int16?, wa_id: String?, wcc: String?, completion: @escaping (Bool) -> ()) {
        // Look up an object
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDWaypoint")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                for data in result as! [NSManagedObject] {
                    if data.objectID == id {
                        // We have our object
                        // Modify, save, then break
                        data.setValue(Date(), forKey: "date")
                        active != nil ? data.setValue(active, forKey: "active") : print("No new data")
                        address != nil ? data.setValue(address, forKey: "address") : print("No new data")
                        catchment != nil ? data.setValue(catchment, forKey: "catchment") : print("No new data")
                        clearanceTime != nil ? data.setValue(clearanceTime, forKey: "clearanceTime") : print("No new data")
                        colour != nil ? data.setValue(colour, forKey: "colour") : print("No new data")
                        comment != nil ? data.setValue(comment, forKey: "comment") : print("No new data")
                        finalDuty != nil ? data.setValue(finalDuty, forKey: "finalDuty") : print("No new data")
                        finalDutyPoint != nil ? data.setValue(finalDutyPoint, forKey: "finalDutyPoint") : print("No new data")
                        flag != nil ? data.setValue(flag, forKey: "flag") : print("No new data")
                        hub != nil ? data.setValue(hub, forKey: "hub") : print("No new data")
                        keep != nil ? data.setValue(keep, forKey: "keep") : print("No new data")
                        keyNumber != nil ? data.setValue(keyNumber, forKey: "keyNumber") : print("No new data")
                        labelDate != nil ? data.setValue(labelDate, forKey: "labelDate") : print("No new data")
                        labelInner != nil ? data.setValue(labelInner, forKey: "labelInner") : print("No new data")
                        labelOuter != nil ? data.setValue(labelOuter, forKey: "labelOuter") : print("No new data")
                        lat != nil ? data.setValue(lat, forKey: "lat") : print("No new data")
                        long != nil ? data.setValue(long, forKey: "long") : print("No new data")
                        name != nil ? data.setValue(name, forKey: "name") : print("No new data")
                        nat_id != nil ? data.setValue(nat_id, forKey: "nat_id") : print("No new data")
                        postcode != nil ? data.setValue(postcode, forKey: "postcode") : print("No new data")
                        state != nil ? data.setValue(state, forKey: "state") : print("No new data")
                        suburb != nil ? data.setValue(suburb, forKey: "suburb") : print("No new data")
                        sundayClearance != nil ? data.setValue(sundayClearance, forKey: "sunClearance") : print("No new data")
                        sundayClearanceTime != nil ? data.setValue(sundayClearanceTime, forKey: "sunClearanceTime") : print("No new data")
                        type != nil ? data.setValue(type, forKey: "type") : print("No new data")
                        wa_id != nil ? data.setValue(wa_id, forKey: "wa_id") : print("No new data")
                        wcc != nil ? data.setValue(wcc, forKey: "wcc") : print("No new data")
                        
                        do {
                            try context.save()
                            print("Saved")
                            completion(true)
                        } catch let error {
                            print("Error saving SPB: \(error.localizedDescription)")
                            completion(false)
                        }
                        
                    }
                }
            } else {
                // No result found
                completion(false)
            }
        } catch {
            print("Load failed")
            
        }
    }
    
    func editWaypointFromNatID(active: Bool?, address: String?, catchment: String?, clearanceTime: String?, colour: String?, comment: String?, finalDuty: String?, finalDutyPoint: Int16?, flag: String?, hub: String?, keep: Bool?, keyNumber: String?, labelDate: Date?, labelInner: String?, labelOuter: String?, lat: Double?, long: Double?, name: String?, nat_id: String?, postcode: String?, state: String?, suburb: String?, sundayClearance: Bool?, sundayClearanceTime: String?, type: Int16?, wa_id: String?, wcc: String?, completion: @escaping (Bool) -> ()) {
        // Look up an object
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDWaypoint")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                for data in result as! [NSManagedObject] {
                    if data.value(forKey: "nat_id") as? String == nat_id && data.value(forKey: "nat_id") as? String != "NEW" {
                        // We have our object
                        // Modify, save, then break
                        data.setValue(Date(), forKey: "date")
                        active != nil ? data.setValue(active, forKey: "active") : print("No new data")
                        address != nil ? data.setValue(address, forKey: "address") : print("No new data")
                        catchment != nil ? data.setValue(catchment, forKey: "catchment") : print("No new data")
                        clearanceTime != nil ? data.setValue(clearanceTime, forKey: "clearanceTime") : print("No new data")
                        colour != nil ? data.setValue(colour, forKey: "colour") : print("No new data")
                        comment != nil ? data.setValue(comment, forKey: "comment") : print("No new data")
                        finalDuty != nil ? data.setValue(finalDuty, forKey: "finalDuty") : print("No new data")
                        finalDutyPoint != nil ? data.setValue(finalDutyPoint, forKey: "finalDutyPoint") : print("No new data")
                        flag != nil ? data.setValue(flag, forKey: "flag") : print("No new data")
                        hub != nil ? data.setValue(hub, forKey: "hub") : print("No new data")
                        keep != nil ? data.setValue(keep, forKey: "keep") : print("No new data")
                        keyNumber != nil ? data.setValue(keyNumber, forKey: "keyNumber") : print("No new data")
                        labelDate != nil ? data.setValue(labelDate, forKey: "labelDate") : print("No new data")
                        labelInner != nil ? data.setValue(labelInner, forKey: "labelInner") : print("No new data")
                        labelOuter != nil ? data.setValue(labelOuter, forKey: "labelOuter") : print("No new data")
                        lat != nil ? data.setValue(lat, forKey: "lat") : print("No new data")
                        long != nil ? data.setValue(long, forKey: "long") : print("No new data")
                        name != nil ? data.setValue(name, forKey: "name") : print("No new data")
                        nat_id != nil ? data.setValue(nat_id, forKey: "nat_id") : print("No new data")
                        postcode != nil ? data.setValue(postcode, forKey: "postcode") : print("No new data")
                        state != nil ? data.setValue(state, forKey: "state") : print("No new data")
                        suburb != nil ? data.setValue(suburb, forKey: "suburb") : print("No new data")
                        sundayClearance != nil ? data.setValue(sundayClearance, forKey: "sunClearance") : print("No new data")
                        sundayClearanceTime != nil ? data.setValue(sundayClearanceTime, forKey: "sunClearanceTime") : print("No new data")
                        type != nil ? data.setValue(type, forKey: "type") : print("No new data")
                        wa_id != nil ? data.setValue(wa_id, forKey: "wa_id") : print("No new data")
                        wcc != nil ? data.setValue(wcc, forKey: "wcc") : print("No new data")
                        
                        do {
                            try context.save()
                            print("Saved")
                            completion(true)
                        } catch let error {
                            print("Error saving SPB: \(error.localizedDescription)")
                            completion(false)
                        }
                        
                    }
                }
            } else {
                // No result found
                completion(false)
            }
        } catch {
            print("Load failed")
            
        }
    }
    
    func editRoute(oldName: String, newName: String, newKeep: Bool, newWaypoints: [CDWaypoint]) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDRoute")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                for data in result as! [CDRoute] {
                    if data.value(forKey: "name") as! String == oldName {
                        // We've found the object to be edited
                        data.setValue(newName, forKey: "name")
                        data.setValue(newKeep, forKey: "keep")
                        data.setValue(Date(), forKey: "date")
                        //newRoute.addToWaypoints(NSSet(array: waypoints))
                        data.removeFromWaypoints(data.waypoints!)
                        data.addToWaypoints(NSOrderedSet(array: newWaypoints))
                        do {
                            try context.save()
                        } catch let error {
                            print("Error saving SPB: \(error.localizedDescription)")
                        }
                    }
                }
            }
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    func deleteRoute(name: String) -> Bool {
        print("Attempting to delete route: \(name)")
        if checkIfNameAvailable(name: name) {
            // If the name is available, it has not been used therefore cannot be deleted
            print("Error: Name not in use")
            return false
        }
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        if let route = loadRoute(name: name) {
            context.delete(route)
            do {
                try context.save()
                print("Saved deletion")
            } catch let error {
                print("Error saving deletion: \(error.localizedDescription)")
                return false
            }
            
        } else {
            print("No route of that name found?")
        }
        return true
    }
}
