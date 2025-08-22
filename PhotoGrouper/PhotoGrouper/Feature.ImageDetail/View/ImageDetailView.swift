//
//  ImageDetailView.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import SwiftUI

struct ImageDetailView: View {
    let photos: [SamplePhoto]
    @State var index: Int
    
    init(photos: [SamplePhoto], startIndex: Int) {
        self.photos = photos
        self._index = State(initialValue: min(max(0, startIndex), photos.count-1))
    }
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            TabView(selection: $index) {
                ForEach(Array(photos.enumerated()), id: \.offset) { i, item in
                    GeometryReader { proxy in
                        Image(item.name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: proxy.size.width, height:  proxy.size.height)
                            .background(Color.black)
                            .tag(i)
                        
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
