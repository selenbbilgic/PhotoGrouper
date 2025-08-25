//
//  PhotoAssetRecord.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//
import Foundation
import Photos

struct GroupingResult: Codable, Equatable {
    var groups: [PhotoGroup: [String]]
    var others: [String]
    
    init() {
        self.groups = [:]
        self.others = []
    }
    
    func count(for group: PhotoGroup) -> Int {
        return groups[group]?.count ?? 0
    }
    
    var otherCount: Int {
        return others.count
    }
}
