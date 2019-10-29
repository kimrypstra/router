//
//  Parser.swift
//  Router
//
//  Created by Kim Rypstra on 5/1/19.
//  Copyright © 2019 Kim Rypstra. All rights reserved.
//

import Foundation

extension String {
    var rtrim: String {
        var s = self.characters
        while s.last == " " { s = String(s.dropLast()) }
        return String(s)
    }
    var ltrim: String {
        var s = self.characters
        while s.first == " " { s = String(s.dropFirst()) }
        return String(s)
    }
    var trim:String {
        return self.ltrim.rtrim
    }
}

class Parser {
    func readCSV(name: String) -> String? {
        guard let path = Bundle.main.path(forResource: name, ofType: "csv") else {
            print("Can't get path for file")
            return nil
        }
        do {
            let file = try String(contentsOfFile: path, encoding: .utf8)
            return file 
        } catch let error {
            print("Error reading: \(error)")
            return nil
        }
    }
    
    func parseCSV(csv: String) {
        let cdMan = CoreDataManager()
        
        let cleaned = cleanCSV(csv: csv)
        let rows = cleaned.components(separatedBy: "\n")
        for (index, row) in rows.enumerated() {
            let columns = row.components(separatedBy: ",")
            let WA_ID = columns[0]
            let colour = columns[1]
            let NAT_ID = columns[2]
            let postcode = columns[3]
            let catchment = columns[4]
            if catchment == "WA Rural and Remote" {
                print("Outside area")
                continue
            }
            var name = columns[5]
            
            let address = columns[6]
            let workCentreCode = columns[7] // Only for SPBs outside a facility
            let suburb = columns[8]
            let state = columns[9]
            
            let activeValue = columns[10] // Bool
            var active: Bool = true
//            if activeValue != "Yes" {
//                active = false
//            }
                
            let labeldateValue = columns[11] // Date
            var labelDate: Date?
            
            if labeldateValue != nil && labeldateValue != "" {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/mm/yy"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                labelDate = formatter.date(from: labeldateValue)
            } else {
                labelDate = Date(timeIntervalSince1970: 0)
            }
            
            
            let labelOuter = columns[12]
            let labelInner = columns[13]
            let clearanceTime = columns[14]
            let sunClearanceTime = columns[15]
            
            let sunClearanceValue = columns[16] // Has a Sunday clearance? // Bool
            var sunClearanceBool = true
            if sunClearanceValue != "Yes" {
                sunClearanceBool = false
            }
            
            var type = Type.SPB
            let typeValue = columns[17] // Hanger, pedo etc. // Int16
            switch typeValue {
            case "Single Hanger":
                type = .SPB
            case "Double Hanger":
                type = .SPB
            case "Pedestal":
                type = .Pedestal
            default:
                type = .SPB
            }
            
            if colour == "Gold" {
                type = .Express
            }
            
            let keyNumber = columns[18] // Probably shouldn't use this
            
            let lonValue = columns[19] // Double
            let latValue = columns[20] // Double
            guard lonValue != "#N/A" && latValue != "#N/A" && latValue != "" && lonValue != "" else {
                print("\(name) has no coordinates")
                continue
            }
            let lon = Double(lonValue)

            let lat = Double(latValue)
            
            let comment = "comment" // Probably useless
            let finalDuty = columns[21] // Duty number for M-F, probably no good for me since I want Sunday
            
            let finalDutyPointValue: Int16 = 0
            
            let hub = columns[23]
            let flag = columns[24] // Doesn't contain anything useful
            
            cdMan.addSPBFromFile(active: active, address: address, catchment: catchment, clearanceTime: clearanceTime, colour: colour, comment: comment, finalDuty: finalDuty, finalDutyPoint: finalDutyPointValue, flag: flag, hub: hub, keep: true, keyNumber: keyNumber, labelDate: labelDate!, labelInner: labelInner, labelOuter: labelOuter, lat: lat!, long: lon!, name: name, nat_id: NAT_ID, postcode: postcode, state: state, suburb: suburb, sundayClearance: sunClearanceBool, sundayClearanceTime: sunClearanceTime, type: Int16(type.rawValue), wa_id: WA_ID, wcc: workCentreCode)
            
        }
        print("Lines: \(rows.count)")
    }
    
    func modifyBasedOnID(csv: String) {
        let cdMan = CoreDataManager()
        
        let cleaned = cleanCSV(csv: csv)
        let rows = cleaned.components(separatedBy: "\n")
        for (index, row) in rows.enumerated() {
            let columns = row.components(separatedBy: ",")
            let WA_ID = columns[0]
            let colour = columns[1]
            let NAT_ID = columns[2]
            let postcode = columns[3]
            let catchment = columns[4]
            if catchment == "WA Rural and Remote" {
                print("Outside area")
                continue
            }
            var name = columns[5]
            let address = columns[6]
            let workCentreCode = columns[7] // Only for SPBs outside a facility
            let suburb = columns[8]
            let state = columns[9]
            
            let activeValue = columns[10] // Bool
            var active: Bool = true
            //            if activeValue != "Yes" {
            //                active = false
            //            }
            
            let labeldateValue = columns[11] // Date
            var labelDate: Date?
            
            if labeldateValue != nil && labeldateValue != "" {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/mm/yy"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                labelDate = formatter.date(from: labeldateValue)
            } else {
                labelDate = Date(timeIntervalSince1970: 0)
            }
            
            
            let labelOuter = columns[12]
            let labelInner = columns[13]
            let clearanceTime = columns[14]
            let sunClearanceTime = columns[15]
            
            let sunClearanceValue = columns[16] // Has a Sunday clearance? // Bool
            var sunClearanceBool = true
            if sunClearanceValue != "Yes" {
                sunClearanceBool = false
            }
            
            var type = Type.SPB
            let typeValue = columns[17] // Hanger, pedo etc. // Int16
            switch typeValue {
            case "Single Hanger":
                type = .SPB
            case "Double Hanger":
                type = .SPB
            case "Pedestal":
                type = .Pedestal
            default:
                type = .SPB
            }
            
            if colour == "Gold" || colour == "Both" {
                type = .Express
            }
            
            let keyNumber = columns[18] // Probably shouldn't use this
            
            let lonValue = columns[19] // Double
            let latValue = columns[20] // Double
            guard lonValue != "#N/A" && latValue != "#N/A" && latValue != "" && lonValue != "" else {
                print("\(name) has no coordinates")
                continue
            }
            let lon = Double(lonValue)
            
            let lat = Double(latValue)
            
            let comment = "comment" // Probably useless
            let finalDuty = columns[21] // Duty number for M-F, probably no good for me since I want Sunday
            
            let finalDutyPointValue: Int16 = 0
            
            let hub = columns[23]
            let flag = columns[24] // Doesn't contain anything useful
            
            cdMan.editWaypointFromNatID(active: active, address: address, catchment: catchment, clearanceTime: clearanceTime, colour: colour, comment: comment, finalDuty: finalDuty, finalDutyPoint: finalDutyPointValue, flag: flag, hub: hub, keep: true, keyNumber: keyNumber, labelDate: labelDate, labelInner: labelInner, labelOuter: labelOuter, lat: lat, long: lon, name: name, nat_id: NAT_ID, postcode: postcode, state: state, suburb: suburb, sundayClearance: sunClearanceBool, sundayClearanceTime: sunClearanceTime, type: Int16(type.rawValue), wa_id: WA_ID, wcc: workCentreCode) { (success) in
                if !success {
                    print("Couldn't save \(name)")
                }
            }
        }
    }
    
    func cleanCSV(csv: String) -> String {
        var cleaned = csv
//        cleaned = cleaned.replacingOccurrences(of: "\r", with: "\n")
//        cleaned = cleaned.replacingOccurrences(of: ", ", with: " ")
//        cleaned = cleaned.replacingOccurrences(of: ",,,,,,,,,,,,,,,,,,,,,,,,,", with: "")
//        cleaned = cleaned.replacingOccurrences(of: "\n\n", with: "")
//        cleaned = cleaned.trim
        return csv
    }
    
}
