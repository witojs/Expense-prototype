//
//  Item.swift
//  Expense-prototype
//
//  Created by Wito Irawan on 14/03/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
