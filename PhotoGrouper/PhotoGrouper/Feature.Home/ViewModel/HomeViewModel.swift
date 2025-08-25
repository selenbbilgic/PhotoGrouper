//
//  HomeViewModel.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

final class HomeViewModel {
    struct Output {
        let displays: [GroupDisplay]
        let processed: Int
        let total: Int
        let percent: Double
    }
    
    var onOutput: ((Output) -> Void)?
    
    private let photoLib = PhotoLibraryService()
    private let scanner = ScanEngine()
    
    private var latestCounts: [PhotoGroup: Int] = [:]
    private var latestOthers: Int = 0
    
    private var idsByGroup: [PhotoGroup: [String]] = [:]
    private var otherIDs: [String] = []
    
    private var total: Int = 0
    private var processed: Int = 0
    
    func startScan() {
        photoLib.requestAuthorization { [weak self] granted in
            guard let self, granted else { return}
            let assets = self.photoLib.fetchAllImageAssets()
            self.total = assets.count
            self.processed = 0
            self.latestCounts = [:]
            self.latestOthers = 0
            
            self.reset() 
            self.pushOutput()
            
            self.scanner.scan(assets: assets, callbacks: .init(
                onPartial: { [weak self] groupOpt, id in
                    guard let self else { return }
                    switch groupOpt {
                    case .some(let g):
                        var arr = self.idsByGroup[g] ?? []
                        arr.append(id)
                        self.idsByGroup[g] = arr
                    case .none:
                        self.otherIDs.append(id)
                    }
                },
                onProgress: { [weak self] state in
                    guard let self else { return }
                    self.processed = state.processed
                    print("selen", processed)
                    self.total = state.total
                    self.latestCounts = state.groupCounts
                    self.latestOthers = state.otherCounts
                    self.pushOutput()
                },
                onComplete: { [weak self] _ in
                    self?.pushOutput()
                }
                        ))
        }
       
        
    }
    
    func assetIDs(for display: GroupDisplay) -> [String] {
        switch display.kind {
        case .group(let g): return idsByGroup[g] ?? []
        case .others:       return otherIDs
        }
    }

    private func reset() {
        processed = 0
        latestCounts = [:]
        latestOthers = 0
        idsByGroup = [:]
        otherIDs = []
    }

    private func makeDisplays() -> [GroupDisplay] {
        var items: [GroupDisplay] = latestCounts
            .filter { $0.value > 0 }
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { GroupDisplay(kind: .group($0.key), count: $0.value) }

        if latestOthers > 0 {
            items.append(GroupDisplay(kind: .others, count: latestOthers))
        }
        return items
    }

    private func pushOutput() {
        let displays = makeDisplays()
        let pct = total == 0 ? 0 : Double(processed) / Double(total)
        onOutput?(.init(displays: displays, processed: processed, total: total, percent: pct))
    }
}
private extension PhotoGroup {
    var displayTitle: String { "\(self)" }
}
