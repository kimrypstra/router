//
//  Manouver.swift
//  Router
//
//  Created by Kim Rypstra on 15/12/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import Foundation

enum Manouver: String {
    case TurnLeft = "Turn left"
    case TurnRight = "Turn right"
    case Roundabout1 = "At the roundabout, take the first exit"
    case Roundabout2 = "At the roundabout, take the second exit"
    case Roundabout3 = "At the roundabout, take the third exit"
    case Roundabout4 = "At the roundabout, take the fourth exit"
    case Roundabout5 = "At the roundabout, take the fifth exit"
    case Roundabout6 = "At the roundabout, take the sixth exit"
    case Arrive = "Arrive"
    case TakeExit = "Take exit"
    case KeepLeft = "Keep left"
    case KeepRight = "Keep right"
    case BearLeft = "Bear left"
    case BearRight = "Bear right"
    case DestLeft = "destination is on your left"
    case DestRight = "destination is on your right"
    case Unknown = "Unknown"
}

extension Manouver {
    static var array: [Manouver] {
        var a: [Manouver] = []
        switch Manouver.TurnLeft {
        case .TurnLeft:
            a.append(.TurnLeft); fallthrough
        case .TurnRight:
            a.append(.TurnRight); fallthrough
        case .Roundabout1:
            a.append(.Roundabout1); fallthrough
        case .Roundabout2:
            a.append(.Roundabout2); fallthrough
        case .Roundabout3:
            a.append(.Roundabout3); fallthrough
        case .Roundabout4:
            a.append(.Roundabout4); fallthrough
        case .Roundabout5:
            a.append(.Roundabout5); fallthrough
        case .Roundabout6:
            a.append(.Roundabout6); fallthrough
        case .Arrive:
            a.append(.Arrive); fallthrough
        case .TakeExit:
            a.append(.TakeExit); fallthrough
        case .KeepLeft:
            a.append(.KeepLeft); fallthrough
        case .KeepRight:
            a.append(.KeepRight); fallthrough
        case .BearLeft:
            a.append(.BearLeft); fallthrough
        case .BearRight:
            a.append(.BearRight); fallthrough
        case .Unknown:
            a.append(.Unknown)
        case .DestLeft:
            a.append(.DestLeft)
        case .DestRight:
            a.append(.DestRight)
        }
        return a
    }
    
}
