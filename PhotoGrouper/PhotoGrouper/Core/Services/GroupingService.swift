//
//  PhotoLibraryService.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import Foundation

final class GroupingService {
    func groupForHash(_ hash: Double) -> PhotoGroup? {
        PhotoGroup.group(for: hash)
    }
}
