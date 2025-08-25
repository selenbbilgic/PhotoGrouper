//
//  ScanEngine.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//
import Foundation
import Photos

final class ScanEngine {
    private let grouping = GroupingService()
    private let aggregationQueue = DispatchQueue(label: "scan.aggregation.queue", qos: .userInitiated)
    
    struct CallBacks {
        let onPartial: ((PhotoGroup?, String) -> Void)?
        let onProgress: (ScanState) -> Void
        let onComplete: (GroupingResult) -> Void
    }
    
    func scan(assets: [PHAsset], callbacks: CallBacks, concurrency: Int = 4) {
        guard !assets.isEmpty else {
            callbacks.onProgress(.init(total: 0, processed: 0, groupCounts: [:], otherCounts: 0))
            callbacks.onComplete(GroupingResult())
            return
        }
        
        let total = assets.count
        let workQueue = DispatchQueue.global(qos: .userInitiated)
        let group = DispatchGroup()
        let semaphore = DispatchSemaphore(value: max(1, concurrency))
        
        var processed = 0
        var result = GroupingResult()
        
        func emit() {
            let counts = Dictionary(uniqueKeysWithValues: result.groups.map { ($0.key, $0.value.count) })
            let state = ScanState(total: total, processed: processed, groupCounts: counts, otherCounts: result.others.count)
            DispatchQueue.main.async { callbacks.onProgress(state) }
        }
        DispatchQueue.global(qos: .userInitiated).async {
            for asset in assets {
                semaphore.wait()
                group.enter()
                workQueue.async {
                    let id = asset.localIdentifier
                    let h = asset.reliableHash()
                    if let g = self.grouping.groupForHash(h) {
                        self.aggregationQueue.async {
                            var arr = result.groups[g] ?? []
                            arr.append(asset.localIdentifier)
                            result.groups[g] = arr
                            processed += 1
                            DispatchQueue.main.async { callbacks.onPartial?(g, id) }
                            emit()
                            semaphore.signal()
                            group.leave()
                        }
                    }
                    else {
                        self.aggregationQueue.async {
                            result.others.append(asset.localIdentifier)
                            processed += 1
                            DispatchQueue.main.async { callbacks.onPartial?(nil, id) }
                            emit()
                            semaphore.signal()
                            group.leave()
                        }
                    }
                    
                }
            }
        }
        
        group.notify(queue: aggregationQueue) {
            let final = result
            DispatchQueue.main.async {
                callbacks.onComplete(final)
            }
        }
    }
    
    
}
