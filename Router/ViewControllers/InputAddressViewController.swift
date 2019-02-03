//
//  InputAddressViewController.swift
//  Router
//
//  Created by Kim Rypstra on 13/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import UIKit
import MapKit

enum EditingMode {
    case Edit
    case Add
}

enum AddMode {
    case Address
    case Coordinates
    case Map
}

class InputAddressViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addressLine: UITextField!
    @IBOutlet weak var suburb: UITextField!
    @IBOutlet weak var postcode: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var spbSeg: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    
    var recog: UILongPressGestureRecognizer!
    var editingMode: EditingMode!
    var editingWaypoint: CDWaypoint? 
    var addingForTemporaryRoute = false
    var addMode: AddMode = .Address
    var temporaryWaypoints: [CDWaypoint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recog = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressOnMap(_:)))
        mapView.addGestureRecognizer(recog)
        addressLine.delegate = self
        suburb.delegate = self
        postcode.delegate = self
        state.delegate = self
        nameField.delegate = self
        mapView.delegate = self
        latitudeField.delegate = self
        longitudeField.delegate = self
        
        if addingForTemporaryRoute {
            self.navigationItem.title = "Temporary Waypoint"
        } else {
            self.navigationItem.title = "Add Waypoint"
            self.navigationItem.rightBarButtonItems?.removeAll()
        }
        
        if editingMode == .Edit {
            addButton.setTitle("Save", for: .normal)
            self.navigationItem.title = editingWaypoint?.name
            spbSeg.selectedSegmentIndex = Int(editingWaypoint!.type)
            nameField.text = editingWaypoint!.name
            addressLine.text = editingWaypoint!.address
            suburb.text = editingWaypoint!.suburb
            postcode.text = editingWaypoint!.postcode
            latitudeField.text = "\(editingWaypoint!.lat)"
            longitudeField.text = "\(editingWaypoint!.long)"
            let camera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: editingWaypoint!.lat, longitude: editingWaypoint!.long), fromDistance: 300, pitch: 0, heading: 0)
            mapView.setCamera(camera, animated: false)
            let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: editingWaypoint!.lat, longitude: editingWaypoint!.long))
            mapView.addAnnotation(placemark)
        }
    }
    
    func resignAllFirstResponders() {
        let fields: [UITextField] = [self.addressLine, self.suburb, self.postcode, self.state, self.nameField, self.latitudeField, self.longitudeField]
        for field in fields {
            field.resignFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if editingMode == .Add {
            let addressFields: [UITextField] = [addressLine, suburb, postcode, state]
            let coordinateFields: [UITextField] = [latitudeField, longitudeField]
            if addressFields.contains(textField) {
                addMode = .Address
                for field in coordinateFields {
                    field.text = ""
                }
            } else {
                addMode = .Coordinates
                for field in addressFields {
                    field.text = ""
                }
            }
        }
        return true
    }
    
    
    @IBAction func segChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            nameField.placeholder = "Name"
        } else {
            nameField.placeholder = "Name (optional)"
        }
    }
    
    @IBAction func checkButton(_ sender: UIButton) {
        resignAllFirstResponders()
        
        switch addMode {
            case .Address:
                let address = "\(addressLine.text!) \(suburb.text!) \(state.text!) \(postcode.text!)"
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(address) { (placemarks, error) in
                    if error == nil {
                        if let placemark = placemarks?[0] {
                            self.mapView.setCenter(placemark.location!.coordinate, animated: true)
                            //self.mapView.addAnnotation(placemark)
                            let anno = MKPlacemark(placemark: placemark)
                            if !self.addingForTemporaryRoute {
                                self.mapView.removeAnnotations(self.mapView.annotations)
                            }
                            self.mapView.addAnnotation(anno)
                            let camera = MKMapCamera(lookingAtCenter: anno.location!.coordinate, fromDistance: 300, pitch: 0, heading: 0)
                            self.mapView.setCamera(camera, animated: true)
                        }
                    }
                }
            case .Coordinates:
                guard latitudeField.text != nil && longitudeField.text != nil else {
                    print("Incomplete coordinates")
                    return
                }
                let anno = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(latitudeField.text!)!, longitude: Double(longitudeField.text!)!))
                if !addingForTemporaryRoute {
                    mapView.removeAnnotations(mapView.annotations)
                }
                
                mapView.addAnnotation(anno)
                let camera = MKMapCamera(lookingAtCenter: anno.location!.coordinate, fromDistance: 300, pitch: 0, heading: 0)
                mapView.setCamera(camera, animated: true)
            case .Map:
                guard latitudeField.text != nil && longitudeField.text != nil else {
                    print("Incomplete coordinates")
                    return
                }
                let anno = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(latitudeField.text!)!, longitude: Double(longitudeField.text!)!))
                if !addingForTemporaryRoute {
                    mapView.removeAnnotations(mapView.annotations)
                }
                
                mapView.addAnnotation(anno)
                let camera = MKMapCamera(lookingAtCenter: anno.location!.coordinate, fromDistance: 300, pitch: 0, heading: 0)
                mapView.setCamera(camera, animated: true)
        }

        
    }
    
    @IBAction func driveButton(_ sender: UIBarButtonItem) {
        
    }
    
    func resetTextFields() {
        let fields: [UITextField] = [self.addressLine, self.suburb, self.postcode, self.state, self.nameField, self.latitudeField, self.longitudeField]
        for field in fields {
            field.text = ""
            self.state.text = "WA"
        }
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        resignAllFirstResponders()
        
        // We need to add some code here to deal with different modes:
        // Add by coordinate, add by address
        let cdMan = CoreDataManager()
        if editingMode == .Add {
            
            switch spbSeg.selectedSegmentIndex {
            case 0:
                // SPB
                if nameField.text == nil {
                    print("No name")
                    return
                }
            case 1:
                // Pedestal
                if nameField.text == nil {
                    print("No name")
                    return
                }
            case 2:
                // Premesis
                if nameField.text == nil {
                    print("No name")
                    return
                }
            case 3:
                // Waypoint
                print("No name but this is fine.jpg")
            default:
                // Nothing
                print("Error: Unknown seg?")
            }
            
            switch addMode {
            case .Address:
                let address = "\(addressLine.text!) \(suburb.text!) \(state.text!) \(postcode.text!)"
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(address) { (placemarks, error) in
                    if error == nil {
                        if let placemark = placemarks?[0] {
                            let location = placemark.location!
                            let coord = location.coordinate
                            if !self.addingForTemporaryRoute {
                                cdMan.addWaypoint(lat: coord.latitude, long: coord.longitude, name: self.nameField.text!, type: Type(rawValue: self.spbSeg.selectedSegmentIndex)!, keep: true, completion: { (error) in
                                    if error == nil {
                                        // Update the UI
                                        self.resetTextFields()
                                        self.mapView.removeAnnotations(self.mapView.annotations)
                                    } else {
                                        // Leave the UI the same and alert the user
                                    }
                                })
                            } else {
                                // Generate a new CDWaypoint object but don't save it
                                cdMan.createTemporaryWaypoint(lat: coord.latitude, long: coord.longitude, name: "\(self.temporaryWaypoints.count)", type: Type(rawValue: self.spbSeg.selectedSegmentIndex)!, keep: true, completion: { (waypoint) in
                                    self.temporaryWaypoints.append(waypoint)
                                    self.resetTextFields()
                                    // Pass it into an array
                                    // When the 'drive' button is hit, the array will be passed on
                                })
                            }
                        }
                    }
                }
            case .Coordinates:
                guard latitudeField.text != nil && longitudeField.text != nil else {
                    print("Incomplete coordinates")
                    return
                }
                if !addingForTemporaryRoute {
                    cdMan.addWaypoint(lat: Double(latitudeField.text!)!, long: Double(longitudeField.text!)!, name: nameField.text!, type: Type(rawValue: self.spbSeg.selectedSegmentIndex)!, keep: true, completion: { (error) in
                        if error == nil {
                            // Update the UI
                            self.resetTextFields()
                            self.mapView.removeAnnotations(self.mapView.annotations)
                        } else {
                            // Leave the UI the same and alert the user
                        }
                    })
                } else {
                    // Generate a new CDWaypoint object but don't save it
                    cdMan.createTemporaryWaypoint(lat: Double(latitudeField.text!)!, long: Double(longitudeField.text!)!, name: "\(self.temporaryWaypoints.count)", type: Type(rawValue: self.spbSeg.selectedSegmentIndex)!, keep: true, completion: { (waypoint) in
                        self.temporaryWaypoints.append(waypoint)
                        self.resetTextFields()
                        // Pass it into an array
                        // When the 'drive' button is hit, the array will be passed on
                    })
                    
                }
                
            case .Map:
                guard let anno = mapView.annotations.first else {
                    print("No annotation found?")
                    return
                }
                if !addingForTemporaryRoute {
                    cdMan.addWaypoint(lat: anno.coordinate.latitude, long: anno.coordinate.longitude, name: nameField.text!, type: Type(rawValue: self.spbSeg.selectedSegmentIndex)!, keep: true, completion: { (error) in
                        if error == nil {
                            // Update the UI
                            self.resetTextFields()
                            self.mapView.removeAnnotations(self.mapView.annotations)
                            
                        } else {
                            // Leave the UI the same and alert the user
                        }
                    })
                } else {
                    // Generate a new CDWaypoint object but don't save it
                    cdMan.createTemporaryWaypoint(lat: anno.coordinate.latitude, long: anno.coordinate.longitude, name: "\(self.temporaryWaypoints.count)", type: Type(rawValue: self.spbSeg.selectedSegmentIndex)!, keep: true, completion: { (waypoint) in
                        self.temporaryWaypoints.append(waypoint)
                        self.resetTextFields()
                        // Pass it into an array
                        // When the 'drive' button is hit, the array will be passed on
                    })
                }
            }
        } else if editingMode == .Edit {
            cdMan.editWaypoint(id: editingWaypoint!.objectID, active: nil, address: addressLine.text, catchment: nil, clearanceTime: nil, colour: nil, comment: nil, finalDuty: nil, finalDutyPoint: nil, flag: nil, hub: nil, keep: nil, keyNumber: nil, labelDate: nil, labelInner: nil, labelOuter: nil, lat: Double(latitudeField.text!), long: Double(longitudeField.text!), name: nameField.text, nat_id: nil, postcode: postcode.text, state: state.text, suburb: suburb.text, sundayClearance: nil, sundayClearanceTime: nil, type: Int16(spbSeg!.selectedSegmentIndex), wa_id: nil, wcc: nil) { (success) in
                if success {
                    print("Successfully saved edit")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("Problem saving edit")
                    let alert = UIAlertController(title: "Error", message: "Didn't save?", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if addingForTemporaryRoute {
            let alert = UIAlertController(title: "Remove?", message: "Do you want to remove this waypoint?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .destructive) { (action) in
                // remove from map AND from waypoints list
            }
            let no = UIAlertAction(title: "No", style: .default)
            alert.addAction(yes)
            alert.addAction(no)
            self.present(alert, animated: true, completion: nil)
        }
        // check if it should be removed
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("MapView moved")
        resignAllFirstResponders()
    }
    
    @objc func didLongPressOnMap(_ sender: UILongPressGestureRecognizer) {
        resignAllFirstResponders()
        
        recog.isEnabled = false
        // remove all previous annotations
        mapView.removeAnnotations(mapView.annotations)
        // convert the CGPoint to lat/long
        let coord = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
        // move the map
        mapView.setCenter(coord, animated: true)
        // Add an annotation
        let anno = MKPlacemark(coordinate: coord)
        
        mapView.addAnnotation(anno)
        // reverse geocode
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coord.latitude, longitude: coord.longitude)) { (placemarks, error) in
            guard error == nil else {
                print("Error reverse geocoding: \(error?.localizedDescription)")
                return
            }
            if let location = placemarks?.first {
                //self.nearLabel.text = location.makeAddressString()
                // Address, Suburb, Postcode, State
                self.addressLine.text = location.thoroughfare
                self.suburb.text = location.locality
                self.postcode.text = location.postalCode
                self.state.text = location.administrativeArea
                self.latitudeField.text = "\(location.location!.coordinate.latitude)"
                self.longitudeField.text = "\(location.location!.coordinate.longitude)"
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        recog.isEnabled = true
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "driveTempRoute":
            let IVC = segue.destination as! PreviewRouteViewController
            let cdMan = CoreDataManager()
            let route = cdMan.createTemporaryRoute(waypoints: temporaryWaypoints, name: "Temp", keep: false)
            IVC.route = route 
        default:
            print("Error")
        }
    }
}
