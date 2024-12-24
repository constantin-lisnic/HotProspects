//
//  Prospect.swift
//  HotProspects
//
//  Created by Constantin Lisnic on 23/12/2024.
//

import SwiftData
import Foundation

@Model
class Prospect {
    var name: String
    var email: String
    var isContacted: Bool
    var createdAt: Date
    
    init(name: String, email: String, isContacted: Bool) {
        self.name = name
        self.email = email
        self.isContacted = isContacted
        self.createdAt = .now
    }
}
