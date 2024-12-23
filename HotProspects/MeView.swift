//
//  MeView.swift
//  HotProspects
//
//  Created by Constantin Lisnic on 23/12/2024.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    @AppStorage("name") private var name: String = "Anonymous"
    @AppStorage("email") private var email: String = "you@yoursite.com"
    @State private var qrCode = UIImage()

    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .font(.title)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .font(.title)

                Image(uiImage: qrCode)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .contextMenu {
                        ShareLink(
                            item: Image(uiImage: qrCode),
                            preview: SharePreview(
                                "My QR Code", image: Image(uiImage: qrCode)))
                    }
            }
            .navigationTitle("Your code")
            .onAppear(perform: updateCode)
            .onChange(of: name, updateCode)
            .onChange(of: email, updateCode)
        }
    }

    func updateCode() {
        qrCode = generateQRCode(from: "\(name)\n\(email)")
    }

    func generateQRCode(from string: String) -> UIImage{
        filter.message = Data(string.utf8)

        guard let outputImage = filter.outputImage else {return UIImage(systemName: "xmark.circle") ?? UIImage()}
        let scaledImage = outputImage.transformed(by: .init(scaleX: 2, y: 2)) // scale up
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent)else {return UIImage(systemName: "xmark.circle") ?? UIImage()}

        let renderer = UIGraphicsImageRenderer(size: scaledImage.extent.size)
        let finalImage = renderer.image { context in // disable interpolation and antialias
            let cgContext = context.cgContext
            cgContext.interpolationQuality = .none
            cgContext.setShouldAntialias(false)
            cgContext.draw(cgImage, in: scaledImage.extent)
        }
        return finalImage
    }
}

#Preview {
    MeView()
}
