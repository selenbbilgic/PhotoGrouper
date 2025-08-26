//
//  PersistenceService.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import Foundation

final class PersistenceService {
    static let shared =  PersistenceService()
    
    private init() {
        
    }
    
    private var url: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("scan.json")
    }
    
    func load() -> PersistentScan? {
        guard FileManager.default.fileExists(atPath: url.path) else {return nil}
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(PersistentScan.self, from: data)
        }
        catch {
            print("json loading process failed.")
            return nil
        }
    }
    
    func save(_ snapshot: PersistentScan) {
        do {
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: url, options: [.atomic])
        }
        catch {
            print("data saving process failed.")
        }
    }
    
    func clear() {
        try? FileManager.default.removeItem(at: url)
    }
}
