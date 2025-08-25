//
//  ScanState.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import Foundation

struct ScanState: Equatable {
    let total: Int
    let processed: Int
    let groupCounts: [PhotoGroup: Int]
    let otherCounts: Int
    
    var percent: Double {
        guard total > 0 else {
            return 0
        }
        return Double(processed) / Double(total)
    }
}
