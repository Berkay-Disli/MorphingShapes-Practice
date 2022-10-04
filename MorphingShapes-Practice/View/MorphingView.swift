//
//  MorphingView.swift
//  MorphingShapes-Practice
//
//  Created by Berkay Disli on 4.10.2022.
//

import SwiftUI

struct MorphingView: View {
    @State private var currentImage: CustomShapes = .cloud
    @State private var pickerImage: CustomShapes = .cloud
    @State private var animateMorph = false
    @State private var blurRadius: CGFloat = 0
    
    var body: some View {
        VStack {
            Canvas { context, size in
                context.addFilter(.alphaThreshold(min: 0.5))
                context.addFilter(.blur(radius: blurRadius >= 20 ? 20 - (blurRadius - 20) : blurRadius))
                
                context.drawLayer { ctx in
                    if let resolvedImage = context.resolveSymbol(id: 1) {
                        ctx.draw(resolvedImage, at: CGPoint(x: size.width / 2, y: size.height / 2))
                    }
                }
            } symbols: {
                ResolvedImage(currentImage: $currentImage)
                    .tag(1)
            }
            .frame(height: 350)
            .onReceive(Timer.publish(every: 0.007, on: .main, in: .common).autoconnect()) { _ in
                if animateMorph {
                    if blurRadius <= 40 {
                        blurRadius += 0.5
                        
                        if blurRadius.rounded() == 20 {
                            currentImage = pickerImage
                        }
                    }
                    
                    if blurRadius.rounded() == 40 {
                        animateMorph = false
                        blurRadius = 0
                    }
                }
            }
            
            Picker("", selection: $pickerImage) {
                ForEach(CustomShapes.allCases, id:\.rawValue) { shape in
                    Image(systemName: shape.rawValue)
                        .tag(shape)
                }
            }
            .pickerStyle(.segmented)
            .overlay(content: {
                Rectangle()
                    .fill(.primary)
                    .opacity(animateMorph ? 0.04:0)
                    .animation(.easeInOut, value: animateMorph)
            })
            .padding(15)
            .onChange(of: pickerImage) { newValue in
                animateMorph = true
            }
            
            /*
            Toggle("Turn off morphing", isOn: $turnOffMorphing)
                .fontWeight(.semibold)
                .padding(.horizontal, 15)
                .padding(.top, 10)
             */
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct MorphingView_Previews: PreviewProvider {
    static var previews: some View {
        MorphingView()
    }
}

struct ResolvedImage: View {
    @Binding var currentImage: CustomShapes
    var body: some View {
        Image(systemName: currentImage.rawValue)
            .font(.system(size: 200))
            .animation(.interactiveSpring(response: 0.7, dampingFraction: 0.7, blendDuration: 0.8), value: currentImage)
            .frame(width: 300, height: 300)
    }
}
