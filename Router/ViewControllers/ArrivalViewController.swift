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
    @IBOutlet weak var upperStackView: UIStackView!
    @IBOutlet weak var lowerStackView: UIStackView!
    @IBOutlet weak var arrivedLabel: UILabel!
    @IBOutlet weak var nextLabel: UILabel!
    var arrivedName: String?
    var nextName: String?
    var delegate: ArrivalViewControllerDelegate!
    var image: UIImage?
    var removeProceedButton = false
    var removeNextField = false
    
    // This VC needs to handle timing - the time from when this view is presented
    // To when it is dismissed
    // then save that in Core Data to keep track of average stop time for better
    // time estimations
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()

    }
    
    @IBAction func walkies(_ sender: UIButton) {
        
    }
    
    
    func setup() {
        guard arrivedName != nil && nextName != nil else {return}
        arrivedLabel.text = arrivedName
        nextLabel.text = nextName
        imageView.image = image
        
        if removeProceedButton {
            print("Removing proceed button")
            lowerStackView.removeArrangedSubview(lowerStackView.arrangedSubviews[1])
        }
        
        if removeNextField {
            print("Removing next field")
            upperStackView.removeArrangedSubview(upperStackView.arrangedSubviews[3])
            upperStackView.removeArrangedSubview(upperStackView.arrangedSubviews[2])
        }
    }
    
    @IBAction func proceedButton(_ sender: Any) {
        delegate.didTapProceed()
    }
    
    @IBAction func endRouteButton(_ sender: Any) {
        delegate.didTapEndRoute()
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
