//
//  GroupDisplay.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import Foundation

enum GroupKind: Hashable {
    case group(PhotoGroup)
    case others
}

struct GroupDisplay: Hashable {
    let id: String
    var title: String
    var count: Int
    let kind: GroupKind
    
    init(kind: GroupKind, count: Int) {
        self.kind = kind
        self.count = count
        switch kind {
        case .group(let g):
            self.title = "\(g)"
            self.id = "group_\(g.rawValue)"
            
        case .others :
            self.title = "Others"
            self.id = "others"
            
        }
    }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (l: GroupDisplay, r: GroupDisplay) -> Bool { l.id == r.id && l.count == r.count
    }
}
