//
//  SelectWaypointsViewController.swift
//  Router
//
//  Created by Kim Rypstra on 13/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import UIKit

class SelectWaypointsViewController: UITableViewController {

    var delegate: WaypointSelectionDelegate!
    var spbs: [CDWaypoint]!
    var premeses: [CDWaypoint]!
    var waypoints: [CDWaypoint]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cdMan = CoreDataManager()
        let result = cdMan.loadAllWaypoints()
        spbs = result.filter({$0.type == 0}) + result.filter({$0.type == 1})
        premeses = result.filter({$0.type == 2})
        waypoints = result.filter({$0.type == 3})
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate.returnFromSelection()
    }
    
    @IBAction func didPressDone(_ sender: UIBarButtonItem) {
        delegate.returnFromSelection()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0: return spbs.count
        case 1: return premeses.count
        case 2: return waypoints.count
        default: return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "SPB"
        case 1: return "Premeses"
        case 2: return "Waypoints"
        default: return "Error"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectWaypointCell", for: indexPath)

        var waypoint: CDWaypoint!
        
        switch indexPath.section {
        case 0: waypoint = spbs[indexPath.row]
        case 1: waypoint = premeses[indexPath.row]
        case 2: waypoint = waypoints[indexPath.row]
        default: waypoint = nil
        }
        
        cell.textLabel?.text = waypoint.name
        cell.detailTextLabel?.text = "\(waypoint.lat), \(waypoint.long)"

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: delegate.didSelectWaypoint(waypoint: spbs[indexPath.row])
        case 1: delegate.didSelectWaypoint(waypoint:premeses[indexPath.row])
        case 2: delegate.didSelectWaypoint(waypoint:waypoints[indexPath.row])
        default: print("Error selecting cell"); return
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: delegate.didDeselectWaypoint(waypoint: spbs[indexPath.row])
        case 1: delegate.didDeselectWaypoint(waypoint:  premeses[indexPath.row])
        case 2: delegate.didDeselectWaypoint(waypoint:  waypoints[indexPath.row])
        default: print("Error deselecting cell"); return
        }
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
