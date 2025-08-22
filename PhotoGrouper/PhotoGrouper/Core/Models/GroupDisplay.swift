//
//  GroupDisplay.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import Foundation

struct GroupDisplay: Hashable {
    let id: String
    var title: String
    var count: Int
    
    init(title: String, count: Int) {
        self.id = title
        self.title = title
        self.count = count
    }
}
