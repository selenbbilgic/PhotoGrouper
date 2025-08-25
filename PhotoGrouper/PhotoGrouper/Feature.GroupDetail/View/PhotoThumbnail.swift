import SwiftUI

struct PhotoThumbnail: View {
    let localIdentifier: String
    @StateObject private var loader = PHImageLoader()

    var body: some View {
        GeometryReader { proxy in
            let side = proxy.size.width  // column width

            ZStack {
                if let img = loader.image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle().fill(Color.secondary.opacity(0.15))
                    ProgressView()
                }
            }
            .frame(width: side, height: side)
            .clipped()
            .cornerRadius(8)
            .onAppear {
                let scale = UIScreen.main.scale
                loader.load(localIdentifier: localIdentifier,
                            targetSize: CGSize(width: side * scale, height: side * scale),
                            contentMode: .aspectFill)
            }
            .onDisappear { loader.cancel() }
        }
        .aspectRatio(1, contentMode: .fit) 
    }
}
