//
//  GroupDetailView.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import SwiftUI
import Photos



struct GroupDetailView: View {
    let groupTitle: String
    let assetIDs: [String]
    
    private struct SelectedAsset: Identifiable {
        let id: String
    }
    
    @State private var selectedAsset: SelectedAsset? = nil
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(assetIDs, id: \.self) { id in
                    PhotoThumbnail(localIdentifier: id)
                                            .onTapGesture {
                                                selectedAsset = SelectedAsset(id: id)
                                            }
                    
                }
                    
            }
            .padding(12)
        }
        .navigationTitle(groupTitle)
        .fullScreenCover(item: $selectedAsset) {
            sel in
            let start = assetIDs.firstIndex(of: sel.id) ?? 0
            ImageDetailView(assetIDs: assetIDs, startIndex: start)
                .onDisappear { selectedAsset = nil }
                
        }
    }
        
}
