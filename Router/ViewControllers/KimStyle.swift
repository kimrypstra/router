//
//  KimStyle.swift
//  Router
//
//  Created by Kim Rypstra on 28/10/19.
//  Copyright © 2019 Kim Rypstra. All rights reserved.
//

import Foundation
import MapboxNavigation

class KimStyle: NightStyle {
    required init() {
        super.init()

        // Use a custom map style.
        mapStyleURL = URL(string: "mapbox://styles/kimrypstra/ck14na6ov22dn1crnrtcicp87")!

        // Specify that the style should be used during the day.
        styleType = .day
    }

    override func apply() {
        super.apply()

        // Begin styling the UI
        // White
        print("applying")
        
        ManeuverView.appearance().primaryColor = .white
        ManeuverView.appearance().secondaryColor = .white
        
        ResumeButton.appearance().backgroundColor =  UIColor.tertiarySystemBackground
        //PrimaryLabel.appearance().normalFont = UIFont.systemFont(ofSize: 32, weight: .black)
        
        DistanceLabel.appearance().valueTextColor = .white
        DistanceLabel.appearance().unitTextColor = .white
        
        NextInstructionLabel.appearance().textColor = .white
        TimeRemainingLabel.appearance().textColor = .white
        DistanceRemainingLabel.appearance().textColor = .white
        ArrivalTimeLabel.appearance().textColor = .white
        CancelButton.appearance().imageView?.tintColor = .white
        SeparatorView.appearance().backgroundColor = .white
        
        // Dark
        InstructionsBannerView.appearance().backgroundColor = UIColor.tertiarySystemBackground
        
        
        NextBannerView.appearance().backgroundColor = UIColor.tertiarySystemBackground
        WayNameView.appearance().backgroundColor = UIColor.tertiarySystemBackground
        WayNameView.appearance().borderColor = .tertiarySystemBackground
        FloatingButton.appearance().backgroundColor = UIColor.tertiarySystemBackground
        
        BottomBannerView.appearance().backgroundColor = UIColor.tertiarySystemBackground
        TopBannerView.appearance().backgroundColor = UIColor.tertiarySystemBackground
        DistanceLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).unitTextColor = .white

    }
}
