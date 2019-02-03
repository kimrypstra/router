//
//  KimButton.swift
//  Router
//
//  Created by Kim Rypstra on 16/1/19.
//  Copyright © 2019 Kim Rypstra. All rights reserved.
//



import UIKit

@IBDesignable class KimButton: UIView, UIGestureRecognizerDelegate {
    
    var button: UIButton!
    @IBInspectable var buttonHeight: CGFloat = 30
    
    var imageView: UIImageView!
    @IBInspectable var image: UIImage!
    var recog: UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.button = UIButton(frame: CGRect(x: 0, y: frame.height - buttonHeight, width: 0, height: buttonHeight))
        self.button.addTarget(self, action: #selector(buttonChanged), for: .allEvents)
        self.imageView.image = image
        recog = UITapGestureRecognizer(target: self, action: #selector(gestureHandler))
        self.imageView.addGestureRecognizer(recog)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Gesture Recognizer
    
    @objc func gestureHandler() {
        // Called when an actual tap is received
        touchUpInside()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Apply the image darkening
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Remove the image darkening
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Probably do nothing
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Remove the image darkening
    }
    
    // MARK:- Button
    
    @objc func buttonChanged() {
        let event = button.allControlEvents
        switch event {
        case .touchUpInside:
            touchUpInside()
        default:
            cancelTouch()
        }
    }
    
    func touchUpInside() {
        
    }
    
    func cancelTouch() {
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
