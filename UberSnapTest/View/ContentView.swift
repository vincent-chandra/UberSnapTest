//
//  ContentView.swift
//  UberSnapTest
//
//  Created by Vincent on 10/03/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var imageTemperature: Double = 0
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    private let valueCool = [-5, -4, -3, -2, -1, 0]
    private let valueWarm = [1, 2, 3, 4, 5]
    @StateObject var imgSaver = ImageSaver()
    
    var body: some View {
        NavigationStack{
            VStack {
                VStack {
                    Slider(value: $imageTemperature, in: Double(valueCool[0])...Double(valueWarm.count), step: 1)
                    Text("Image temperature is \(Int(imageTemperature))")
                }
                VStack {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            if let selectedImageData,
                               let uiImage = UIImage(data: selectedImageData) {
                                let img = OpenCVWrapper.changeTemp(uiImage, imageTemperature)
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                
                            } else {
                                Text("Select a photo")
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            DispatchQueue.main.async {
                                self.imageTemperature = Double(self.valueCool[self.valueCool.count - 1])
                                Task {
                                    // Retrieve selected asset in the form of Data
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        self.selectedImageData = data
                                    }
                                }
                            }
                        }
                        .frame(minHeight: 250)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button(action: {
                        if let selectedImageData,
                           let uiImage = UIImage(data: selectedImageData) {
                            let img = OpenCVWrapper.changeTemp(uiImage, imageTemperature)
                            
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: img)
                            imgSaver.isDisplayingAlert.toggle()
                            
                        }
                    }) {
                        Text("Save Image")
                    }
                    .buttonStyle(.borderless)
                    .listRowBackground(EmptyView())
                    .listRowInsets(EdgeInsets())
                }
                Spacer()
            }
            .navigationTitle("IMAGE TEMPERATURE PICKER")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $imgSaver.isDisplayingAlert) { () -> Alert in
                Alert(title: Text("Save Success!"), message: Text("You can see the photo in your gallery!"), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
