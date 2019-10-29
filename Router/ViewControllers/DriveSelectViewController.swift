//
//  DriveSelectViewController.swift
//  Router
//
//  Created by Kim Rypstra on 15/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import UIKit
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class DriveSelectViewController: UITableViewController {

    var routes: [CDRoute] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        let cdMan = CoreDataManager()
        routes = cdMan.loadAllRoutes()!.sorted {$0.name! < $1.name!}
        print("Loaded \(routes.count) routes")
        self.tableView.reloadData()
    }
    
    //MARK: TableView Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return routes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeSelectCell", for: indexPath)
        let route = routes[indexPath.row]
        cell.textLabel?.text = route.name
        cell.accessoryType = .disclosureIndicator
        let filtered = (route.waypoints!.array as! [CDWaypoint]).filter{$0.type == 2}
        if filtered.count > 0 {
            cell.detailTextLabel?.text = "🌕"
        } else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.navigationController?.performSegue(withIdentifier: "driveRoute", sender: self)
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "driveRoute":
            let IVC = segue.destination as! PreviewRouteViewController
            let route = routes[tableView.indexPathForSelectedRow!.row]
            IVC.route = route

        default:
            print("Unknown segue id")
            return
        }
    }
}
