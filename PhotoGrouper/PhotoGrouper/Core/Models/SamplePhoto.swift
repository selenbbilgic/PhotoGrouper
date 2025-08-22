//
//  SamplePhoto.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import Foundation

struct SamplePhoto: Identifiable, Hashable {
    let id: String
    let name: String

    init(name: String) {
        self.id = name
        self.name = name
    }
}

extension SamplePhoto {
    static func mock(count: Int) -> [SamplePhoto] {
        let n = max(1, count)
        return (1...n).map { SamplePhoto(name: "sample\($0)") }
    }
}
