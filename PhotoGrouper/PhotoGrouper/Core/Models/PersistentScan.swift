//
//  PersistentScan.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 25.08.2025.
//

import Foundation

struct PersistentScan: Codable {
    var totalAtSave: Int
    var processedIDs: [String]
    var groupsByRaw: [String: [String]]
    var others: [String]
    var savedAt: Date = Date()
}
