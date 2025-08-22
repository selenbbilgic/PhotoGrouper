//
//  GroupDetailView.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import SwiftUI

struct GroupDetailView: View {
    let groupTitle: String
    let photos: [SamplePhoto]
    
    @State private var showDetail = false
    @State private var selectedIndex: Int? = nil
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(photos.enumerated()), id: \.element) { index, item in
                    Image(item.name)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 100)
                        .clipped()
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedIndex = index
                            showDetail = true
                        }
                    
                }
                    
            }
            .padding(12)
        }
        .navigationTitle(groupTitle)
        .fullScreenCover(isPresented: $showDetail) {
            ImageDetailView(photos: photos, startIndex: selectedIndex ?? 0)
        }
    }
}
