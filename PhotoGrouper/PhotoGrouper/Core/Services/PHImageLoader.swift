//
//  PHImageLoader.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import Foundation
import Photos
import UIKit

final class PHImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let manager = PHCachingImageManager()
    private var requestID: PHImageRequestID = .zero

    func load(localIdentifier: String, targetSize: CGSize, contentMode: PHImageContentMode = .aspectFill) {
        cancel()
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject else {
            return
        }

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true

        requestID = manager.requestImage(for: asset,
                                         targetSize: targetSize,
                                         contentMode: contentMode,
                                         options: options) { [weak self] img, _ in
            self?.image = img
        }
    }

    func loadFull(localIdentifier: String) {
        cancel()
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject else {
            return
        }

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true

        requestID = manager.requestImageDataAndOrientation(for: asset, options: options) { [weak self] data, _, _, _ in
            guard let data, let img = UIImage(data: data) else { return }
            self?.image = img
        }
    }

    func cancel() {
        if requestID != .zero {
            manager.cancelImageRequest(requestID)
            requestID = .zero
        }
    }

    deinit { cancel() }
}
