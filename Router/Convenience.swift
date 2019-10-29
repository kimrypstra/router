//
//  Convenience.swift
//  Router
//
//  Created by Kim Rypstra on 4/9/19.
//  Copyright © 2019 Kim Rypstra. All rights reserved.
//

import Foundation

func formatDate(unformattedDate: Date) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMM yyyy"
    dateFormatter.timeZone = TimeZone(identifier: "GMT+8")
    return dateFormatter.string(from: unformattedDate)
}
