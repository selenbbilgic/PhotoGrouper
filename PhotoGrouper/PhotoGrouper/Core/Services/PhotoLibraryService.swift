//
//  PhotoLibraryService.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import Foundation
import Photos

final class PhotoLibraryService {
    func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        let handler: (PHAuthorizationStatus) -> Void = { status in
            switch status {
            case .authorized, .limited: completion(true)
            default: completion(false)
            }
        }
        
        let current = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if current == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: handler)
        }
        else{
            handler(current)
        }
    }
    
    func fetchAllImageAssets() -> [PHAsset] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: .image, options: options)
        var assets: [PHAsset] = []
        assets.reserveCapacity(result.count)
        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }
}

extension PhotoLibraryService {
    func fetchAssets(withLocalIdentifiers ids: [String]) -> [PHAsset] {
        guard !ids.isEmpty else {return []}
        let res = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil)
        var out: [PHAsset] = []
        out.reserveCapacity(res.count)
        res.enumerateObjects{a, _, _ in out.append(a)}
        return out
    }
}
