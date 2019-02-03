//
//  ViewWaypointsTableViewController.swift
//  Router
//
//  Created by Kim Rypstra on 13/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import UIKit

class ViewWaypointsTableViewController: UITableViewController {

    var spbs: [CDWaypoint]!
    var premeses: [CDWaypoint]!
    var waypoints: [CDWaypoint]!
    @IBOutlet weak var seg: UISegmentedControl!
    var selectedWaypoints: [CDWaypoint]? {
        get {
            switch seg.selectedSegmentIndex {
            case 0: return spbs
            case 1: return premeses
            case 2: return waypoints
            default: return nil
            }
        }
    }
    
    var indexTitles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        
        let cdMan = CoreDataManager()
        let result = cdMan.loadAllWaypoints()

        spbs = result.filter({$0.type == 0}) + result.filter({$0.type == 1})
        premeses = result.filter({$0.type == 2})
        waypoints = result.filter({$0.type == 3})
        
        spbs.sort{$0.name! < $1.name!}
        premeses.sort{$0.name! < $1.name!}
        waypoints.sort{$0.name! < $1.name!}
        
        self.tableView.reloadData()
    }

    @IBAction func segChanged(_ sender: Any) {
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return indexTitles.count
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard selectedWaypoints != nil else {return 0}
        
        let firstLetter = Character(indexTitles[section].lowercased())
        if let filtered = selectedWaypoints?.filter({($0.name?.lowercased().first) == firstLetter}) {
            return filtered.count
        } else {
            return 0
        }
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let firstLetter = Character(indexTitles[indexPath.section].lowercased())
        
        let filtered = selectedWaypoints!.filter({($0.name?.lowercased().first) == firstLetter})
        let waypointForCell = filtered[indexPath.row]
        
        
        cell.textLabel?.text = waypointForCell.name
        cell.detailTextLabel?.text = "\(waypointForCell.lat), \(waypointForCell.long)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        var waypoint: CDWaypoint!
//        
//        switch indexPath.section {
//        case 0: waypoint = spbs[indexPath.row]
//        case 1: waypoint = premeses[indexPath.row]
//        case 2: waypoint = waypoints[indexPath.row]
//        default: waypoint = nil
//        }
        
        // Show it on a map
    }
    


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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewWaypoint" {

            var waypoint: CDWaypoint!
            let indexPath = tableView.indexPathForSelectedRow
            let firstLetter = Character(indexTitles[indexPath!.section].lowercased())
            let filtered = selectedWaypoints!.filter({($0.name?.lowercased().first) == firstLetter})
            waypoint = filtered[indexPath!.row]
            
            let IVC = segue.destination as! InputAddressViewController
            IVC.editingMode = .Edit
            IVC.editingWaypoint = waypoint
            
            tableView.deselectRow(at: indexPath!, animated: false)
        }
        
    }
 

}
