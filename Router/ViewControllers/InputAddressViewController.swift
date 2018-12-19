//
//  InputAddressViewController.swift
//  Router
//
//  Created by Kim Rypstra on 13/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import UIKit
import MapKit

class InputAddressViewController: UIViewController {

    @IBOutlet weak var addressLine: UITextField!
    @IBOutlet weak var suburb: UITextField!
    @IBOutlet weak var postcode: UITextField!
    @IBOutlet weak var state: UITextField!
    
    @IBOutlet weak var keepSwitch: UISwitch!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var spbSeg: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func segChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            nameField.placeholder = "Name"
        } else {
            nameField.placeholder = "Name (optional)"
        }
    }
    
    @IBAction func checkButton(_ sender: UIButton) {
        self.becomeFirstResponder()
        self.resignFirstResponder()
        if state.text == nil {
            state.text = "WA"
        }
        let address = "\(addressLine.text!) \(suburb.text!) \(state.text!) \(postcode.text!)"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    self.mapView.setCenter(placemark.location!.coordinate, animated: true)
                    //self.mapView.addAnnotation(placemark)
                    let anno = MKPlacemark(placemark: placemark)
                    self.mapView.addAnnotation(anno)
                }
            }
        }
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        let cdMan = CoreDataManager()
        let address = "\(addressLine.text!) \(suburb.text!) \(state.text!) \(postcode.text!)"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    let coord = location.coordinate
                    cdMan.addWaypoint(lat: coord.latitude, long: coord.longitude, name: self.nameField.text!, type: Type(rawValue: self.spbSeg.selectedSegmentIndex)!, keep: self.keepSwitch.isOn)
                }
            }
        }
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
