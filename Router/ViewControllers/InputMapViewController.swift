//
//  InputMapViewController.swift
//  Router
//
//  Created by Kim Rypstra on 13/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import UIKit
import MapKit

extension UIView {
    func resignAllFirstResponders() {
        self.resignFirstResponder()
        for subview in self.subviews {
            for subview in subview.subviews {
                for subview in subview.subviews {
                    subview.resignFirstResponder()
                }
            }
            
        }
    }
}

extension CLPlacemark {
    
    func makeAddressString() -> String {
        return [subThoroughfare, thoroughfare, locality, administrativeArea, postalCode, country]
            .flatMap({ $0 })
            .joined(separator: " ")
    }
}

class InputMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var typeSeg: UISegmentedControl!
    @IBOutlet weak var keepSwitch: UISwitch!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var nearLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var recog: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        recog = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressOnMap(_:)))
        //recog.minimumPressDuration = 3
        mapView.addGestureRecognizer(recog)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func typeSegDidChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 || sender.selectedSegmentIndex == 1 {
            nameField.placeholder = "Name"
        } else {
            nameField.placeholder = "Name (optional)"
        }
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        let cdMan = CoreDataManager()
        let coord = mapView.annotations.first!.coordinate
        cdMan.addWaypoint(lat: coord.latitude, long: coord.longitude, name: nameField.text!, type: Type(rawValue: typeSeg.selectedSegmentIndex)!, keep: keepSwitch.isOn)
    }
    
    @objc func didLongPressOnMap(_ sender: UILongPressGestureRecognizer) {
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
                self.nearLabel.text = location.makeAddressString()
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        recog.isEnabled = true
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
