//
//  ArrivalViewController.swift
//  Router
//
//  Created by Kim Rypstra on 2/1/19.
//  Copyright © 2019 Kim Rypstra. All rights reserved.
//

import UIKit

protocol ArrivalViewControllerDelegate {
    func didTapProceed()
    func didTapEndRoute()
}

class ArrivalViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextLabel: UILabel!
    var arrivedName: String?
    var nextName: String?
    var delegate: ArrivalViewControllerDelegate!
    var image: UIImage?
    var finished = false
    @IBOutlet weak var backgroundView: UIView!
    
    // This VC needs to handle timing - the time from when this view is presented
    // To when it is dismissed
    // then save that in Core Data to keep track of average stop time for better
    // time estimations
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = 10
        backgroundView.clipsToBounds = true 
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()

    }
    
    @IBAction func walkies(_ sender: UIButton) {
        
    }
    
    func setup() {
        if finished {
            nextLabel.text = "Finished!"
            imageView.image = nil
        } else {
            nextLabel.text = nextName
            imageView.image = image
        }
    }
    
    @IBAction func proceedButton(_ sender: Any) {
        if finished {
            delegate.didTapEndRoute()
        } else {
            delegate.didTapProceed()
        }
    }
    
    @IBAction func endRouteButton(_ sender: Any) {
        delegate.didTapEndRoute()
    }
}
