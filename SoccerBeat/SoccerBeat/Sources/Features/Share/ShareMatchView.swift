//
//  ShareMatchView.swift
//  SoccerBeat
//
//  Created by Gucci on 12/26/24.
//

import SwiftUI
import PhotosUI

struct ShareMatchView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    @State private var showLayoutComponents = false
    @State private var showDataComponents = false
    @State private var showHeatmapComponents = false
    let matchData: WorkoutData

    // data section
    @State private var showTime = false
    @State private var showDistacne = false
    @State private var showSpeed = false
    @State private var showSprints = false

    private let dataFont = Font.title3
    private let unitFont = Font.caption2
    private let dataKindFont = Font.headline
    private let photoPixel = 35.0 // 30 ~ 40

    var body: some View {
        ZStack {
            VStack {
                // user photo section
                Group {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: photoPixel * 9, height: photoPixel * 16)
                    } else {
                        Color
                            .gray
                            .padding(.horizontal)
                            .frame(width: photoPixel * 9, height: photoPixel * 16)
                            .overlay {
                                PhotosPicker("+", selection: $selectedItem, matching: .images)
                                    .padding()
                                    .onChange(of: selectedItem) { newItem in
                                        Task {
                                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                                               let uiImage = UIImage(data: data) {
                                                selectedImage = uiImage
                                            }
                                        }
                                    }
                            }
                    }
                }
                .overlay {
                    // Data Section
                    VStack(alignment: .leading, spacing: 32) {
                        Spacer()
                            .frame(maxWidth: .infinity)

                        if showTime {
                            VStack(alignment: .leading, spacing: .zero) {
                                Text("79:30")
                                    .font(dataFont)
                                + Text(" Min:Sec")
                                    .font(unitFont)
                                Text("Play time")
                            }
                        }

                        if showDistacne {
                            VStack(alignment: .leading, spacing: .zero) {

                                Text("4.1")
                                    .font(dataFont)
                                + Text(" KM")
                                    .font(unitFont)

                                Text("Distance")
                            }
                        }

                        if showSpeed {
                            VStack(alignment: .leading, spacing: .zero) {
                                Text("25.7")
                                    .font(dataFont)
                                + Text(" KM/H")
                                    .font(unitFont)

                                Text("Max Speed")
                            }
                        }

                        if showSprints {
                            VStack(alignment: .leading, spacing: .zero) {
                                let count = "15"
                                let even = count == "1" ? "" : "s"
                                Text("15")
                                    .font(dataFont)
                                + Text(" Rep\(even)")
                                    .font(unitFont)

                                Text("Sprints")
                            }
                        }
                    }
                    .font(dataKindFont)
                    .foregroundStyle(.gray)

                    // HeatMap Section
                    if showHeatmapComponents {
                        VStack(alignment: .trailing) {
                            Color.mint
                                .frame(width: 320 / 2, height: 200 / 2)

                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
                        .font(.title)
                        .padding(.horizontal)
                    }
                }

                dataComposer()
            }

        }
    }
}

extension ShareMatchView {
    @ViewBuilder
    private func dataComposer() -> some View {
        ScrollView(.horizontal) {
            HStack {
                Button {
                    showLayoutComponents.toggle()
                } label: {
                    Text("Layout")
                }

                if showLayoutComponents {
                    Button {

                    } label: {
                        Text("up")
                    }

                    Button {

                    } label: {
                        Text("down")
                    }

                    Button {

                    } label: {
                        Text("circle")
                    }
                }

                Text("|")

                Button {
                    showDataComponents.toggle()
                } label: {
                    Text("data")
                }

                if showDataComponents {
                    Button {
                        showTime.toggle()
                    } label: {
                        Text("time")
                    }

                    Button {
                        showDistacne.toggle()
                    } label: {
                        Text("distance")
                    }

                    Button {
                        showSpeed.toggle()
                    } label: {
                        Text("speed")
                    }

                    Button {
                        showSprints.toggle()
                    } label: {
                        Text("sprint")
                    }
                }

                Text("|")

                Button {
                    showHeatmapComponents.toggle()
                } label: {
                    Text("heatmap")
                }
            }
        }
        .padding(.horizontal)
        .border(.SprintLeftColor)
        .scrollIndicators(
            .hidden,
            axes: .horizontal
        )
    }
}

#Preview {
    NavigationView {
        ShareMatchView(matchData: WorkoutData.example)
    }
}
