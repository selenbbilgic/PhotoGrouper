//
//  ImageDetailView.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import SwiftUI

struct ImageDetailView: View {
    let assetIDs: [String]
    @State var index: Int
    @Environment(\.dismiss) private var dismiss
    
    init(assetIDs: [String], startIndex: Int) {
        self.assetIDs = assetIDs
        self._index = State(initialValue: min(max(0, startIndex), assetIDs.count-1))
    }
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            TabView(selection: $index) {
                ForEach(assetIDs.indices, id: \.self) { i in
                    GeometryReader { proxy in
                        GeometryReader { proxy in
                                                PhotoFull(localIdentifier: assetIDs[i])
                                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                                    .background(Color.black)
                                                    .tag(i)
                                            }
                                            .ignoresSafeArea()
                        
                    }
                    .ignoresSafeArea()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            VStack{
                HStack{
                    Button {
                        UIApplication.shared.windows.first {$0.isKeyWindow}?.rootViewController?.dismiss(animated: true, completion: nil)
                        
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(12)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
}


private struct PhotoFull: View {
    let localIdentifier: String
    @StateObject private var loader = PHImageLoader()

    var body: some View {
        Group {
            if let img = loader.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView().tint(.white)
            }
        }
        .onAppear { loader.loadFull(localIdentifier: localIdentifier) }
        .onDisappear { loader.cancel() }
    }
}
