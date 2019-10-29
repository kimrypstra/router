//
//  NewRouteViewController.swift
//  Router
//
//  Created by Kim Rypstra on 13/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import UIKit

protocol WaypointSelectionDelegate {
    func didSelectWaypoint(waypoint: CDWaypoint)
    func didDeselectWaypoint(waypoint: CDWaypoint)
    func returnFromSelection()
    func isWaypointSelected(waypoint: CDWaypoint) -> Bool
}

class NewRouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WaypointSelectionDelegate {
    
    var mode: EditingMode!
    var editingRoute: CDRoute?
    
    var selectedWaypoints: [CDWaypoint] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameField: UITextField!

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeWaypointCell", for: indexPath)
        cell.textLabel?.text = selectedWaypoints[indexPath.row].name
        cell.detailTextLabel?.text = "\(selectedWaypoints[indexPath.row].lat), \(selectedWaypoints[indexPath.row].long)"
        
        return cell
    }
    
    func isWaypointSelected(waypoint: CDWaypoint) -> Bool {
        return selectedWaypoints.contains(waypoint)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Selected waypoints: \(selectedWaypoints.count)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isEditing = true
        
        if mode == .Edit {
            // Populate selectedWaypoints with the waypoints from the selected route
            selectedWaypoints = editingRoute?.waypoints?.array as! [CDWaypoint]
            nameField.text = editingRoute?.name!
        }
    }
    
    func didSelectWaypoint(waypoint: CDWaypoint) {
        selectedWaypoints.append(waypoint)
    }
    
    func didDeselectWaypoint(waypoint: CDWaypoint) {
        if selectedWaypoints.contains(waypoint) {
            selectedWaypoints.remove(at: selectedWaypoints.firstIndex(of: waypoint)!)
        }
    }
    
    func returnFromSelection() {
        print("Returning from selection with \(selectedWaypoints.count) selected")
        tableView.reloadData()
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        guard nameField.text != nil && selectedWaypoints.count > 0 else {
            print("Incomplete")
            return
        }
        var success = true
        // TODO:- Make cdMan methods return a success bool so we can confirm it worked before dismissing
        
        let cdMan = CoreDataManager()
        if mode! == .Add {
            cdMan.newRouteWithWaypoints(waypoints: selectedWaypoints, name: nameField.text!, keep: true)
        } else if mode! == .Edit {
            guard editingRoute != nil else {
                print("Editing route is nil")
                return
            }
            cdMan.editRoute(oldName: editingRoute!.name!, newName: nameField.text!, newKeep: true, newWaypoints: selectedWaypoints)
        }
        
        if success {
            self.navigationController?.popToRootViewController(animated: true)
            print("Dismissed?")
        }
    }
    
    // MARK: - Table view data source
    @IBAction func didTapDoneTextField(_ sender: Any) {
        nameField.resignFirstResponder()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return selectedWaypoints.count
    }
    
    /*
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    */
    /*
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false 
    }
    */
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            selectedWaypoints.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // Override to support rearranging the table view.
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let moving = selectedWaypoints[fromIndexPath.row]
        selectedWaypoints.remove(at: fromIndexPath.row)
        selectedWaypoints.insert(moving, at: to.row)
    }
    

    /*
    // Override to support conditional rearranging of the table view.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "selectWaypoints":
            guard let IVC = segue.destination as? SelectWaypointsViewController else {
                print("Error seguening")
                return
            }
            IVC.delegate = self
        case "previewRoute":
            guard let IVC = segue.destination as? PreviewRouteViewController else {
                print("Error segueing")
                return
            }
            if editingRoute != nil {
                // We are editing a route
                IVC.route = editingRoute
                IVC.shouldAllowDrive = false 
            } else {
                // We are viewing a route
                IVC.route = CoreDataManager().createTemporaryRoute(waypoints: selectedWaypoints, name: nameField.text!, keep: false)
                IVC.shouldAllowDrive = false 
            }
            
        default:
            print("Unknown segue id")
            return
        }
        
        
        if segue.identifier == "selectWaypoints" {
            
        }
    }


}
