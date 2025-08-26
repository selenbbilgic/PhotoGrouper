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
    
    private let persistence = PersistenceService.shared
    
    private var latestCounts: [PhotoGroup: Int] = [:]
    private var latestOthers: Int = 0
    private var idsByGroup: [PhotoGroup: [String]] = [:]
    private var otherIDs: [String] = []
    
    private var processedIDs: Set<String> = []
    
    private var total: Int = 0
    private var processed: Int = 0
    
    private var unsavedSinceLastSave = 0
    private var saveTreshold = 25
    
    func startScan() {
        photoLib.requestAuthorization { [weak self] granted in
            guard let self, granted else { return}
            let assets = self.photoLib.fetchAllImageAssets()
            let allIDs = Set(assets.map {$0.localIdentifier})
            
            if let snap = self.persistence.load() {
                self.restore(from: snap, allIDs: allIDs)
                print("Resume: \(processedIDs.count)/\(total) already processed")
            }
            else {
                self.reset()
            }
            self.total = allIDs.count
            self.pushOutput()
            
            let remainingIDs = Array(allIDs.subtracting(self.processedIDs))
            guard !remainingIDs.isEmpty else {
                // already completed.
                self.saveSnapshot()
                return
            }
            
            let remainingAssets = self.photoLib.fetchAssets(withLocalIdentifiers: remainingIDs)
            
            self.scanner.scan(assets: remainingAssets, callbacks: .init(
                onPartial: { [weak self] groupOpt, id in
                    guard let self else { return }
                    self.processedIDs.insert(id)
                    switch groupOpt {
                    case .some(let g):
                        var arr = self.idsByGroup[g] ?? []
                        arr.append(id)
                        self.idsByGroup[g] = arr
                    case .none:
                        self.otherIDs.append(id)
                    }
                    
                    self.unsavedSinceLastSave += 1
                    if self.unsavedSinceLastSave >= self.saveTreshold {
                        self.saveSnapshot()
                        self.unsavedSinceLastSave = 0
                    }
                },
                onProgress: { [weak self] state in
                    guard let self else { return }
                    self.latestCounts = self.idsByGroup.mapValues { $0.count }
                    self.latestOthers = self.otherIDs.count
                    self.processed = self.processedIDs.count
                    self.pushOutput()
                },
                onComplete: { [weak self] _ in
                    guard let self else {return}
                    self.saveSnapshot()
                    self.pushOutput()
                    
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
    
    func saveSnapshot() {
        let snap = makeSnapshot()
        persistence.save(snap)
    }
    
    private func makeSnapshot() -> PersistentScan {
        var groupsByRaw: [String: [String]] = [:]
        for (g, ids) in idsByGroup {
            groupsByRaw[g.rawValue] = ids
        }
        return PersistentScan(totalAtSave: total, processedIDs: Array(processedIDs), groupsByRaw: groupsByRaw, others: otherIDs)
    }
    
    private func restore(from snap: PersistentScan, allIDs: Set<String>) {
        processedIDs = Set(snap.processedIDs).intersection(allIDs)
        idsByGroup.removeAll(keepingCapacity: true)
        for(raw, ids) in snap.groupsByRaw {
            if let g = PhotoGroup(rawValue: raw) {
                idsByGroup[g] = ids.filter { allIDs.contains($0) }
            }
        }
        
        otherIDs = snap.others.filter {allIDs.contains($0)}
        latestCounts = idsByGroup.mapValues {$0.count}
        latestOthers = otherIDs.count
        
        processed = processedIDs.count
    }

    private func reset() {
        processed = 0
        latestCounts = [:]
        latestOthers = 0
        idsByGroup = [:]
        otherIDs = []
        processedIDs = []
        unsavedSinceLastSave = 0
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
        let pct = total == 0 ? 0 : Double(processedIDs.count) / Double(total)
        onOutput?(.init(displays: displays, processed: processedIDs.count, total: total, percent: pct))
    }
    
    private func currentGroupingResult() -> GroupingResult {
        var res = GroupingResult()
        res.groups = idsByGroup
        res.others = otherIDs
        return res
    }
}
private extension PhotoGroup {
    var displayTitle: String { "\(self)" }
}
