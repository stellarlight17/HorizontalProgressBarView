import SwiftUI
import UIKit

public struct HorizontalProgressBarView: View {
    @Binding var progressValue: Double
    @State var height: CGFloat = 30
    @State var cornerRadius: CGFloat = 5
    @State var scaleFactorOnDrag: Double = 1.5
    @State var foregroundColor: Color = .white
    @State var backgroundColor: Color = .white.opacity(0.5)
    
    @State var onDragging: ((Double) -> Void)? = nil
    @State var onDraggingEnded: ((Double) -> Void)? = nil
    
    @State private var dragging: Bool = false
    @State private var progressBarContainerWidth: Double = 0
    @State private var progressBarWidth: Double = 0
    @State private var progressBarWidthOnDrag: Double? = nil
    
    @State private var touchTorelence: CGFloat = 30
    
    public init(progressValue: Binding<Double>, height: CGFloat = 30, cornerRadius: CGFloat = 5, scaleFactorOnDrag: Double = 1.5, foregroundColor: Color = .white, backgroundColor: Color = .white.opacity(0.5), onDragging: ((Double) -> Void)? = nil, onDraggingEnded: ((Double) -> Void)? = nil) {
        self._progressValue = progressValue
        self._height = State(initialValue: height)
        self._cornerRadius = State(initialValue: cornerRadius)
        self._scaleFactorOnDrag = State(initialValue: scaleFactorOnDrag)
        self._foregroundColor = State(initialValue: foregroundColor)
        self._backgroundColor = State(initialValue: backgroundColor)
        self._onDragging = State(initialValue: onDragging)
        self._onDraggingEnded = State(initialValue: onDraggingEnded)
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack {
                GeometryReader { geometryReader in
                    let dragGesture = DragGesture().onChanged { value in
                        let comparedValue = self.progressBarWidthOnDrag ?? self.progressBarWidth
                        if value.startLocation.x < comparedValue - self.touchTorelence || value.startLocation.x > comparedValue + self.touchTorelence {
                            return
                        }
                        
                        withAnimation {
                            self.dragging = true
                            if self.progressBarWidthOnDrag == nil {
                                self.progressBarWidthOnDrag = self.progressBarWidth
                            }
                            let value = max(0, min(self.progressBarWidthOnDrag! + value.translation.width, self.progressBarContainerWidth))
                            self.progressBarWidth = value
                            self.onDragging?(self.progressBarContainerWidth > 0 ? self.progressBarWidth / self.progressBarContainerWidth : 0)
                        }
                    }.onEnded { value in
                        if !self.dragging {
                            return
                        }
                        withAnimation {
                            self.dragging = false
                            self.progressBarWidthOnDrag = nil
                            self.onDraggingEnded?(self.progressBarContainerWidth > 0 ? self.progressBarWidth / self.progressBarContainerWidth : 0)
                        }
                    }
                                        
                    HStack(spacing: 0) {
                        Rectangle().fill(self.foregroundColor).frame(width: self.progressBarWidth).frame(height: self.height).gesture(dragGesture).clipped(antialiased: true)
                        Spacer().frame(minWidth: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .background(self.backgroundColor)
                    .cornerRadius(self.cornerRadius)
                    .scaleEffect(x: 1.0, y: self.dragging ? self.scaleFactorOnDrag : 1.0)
                    .gesture(dragGesture)
                    .onAppear {
                        self.progressBarContainerWidth = geometryReader.size.width
                        self.progressBarWidth = self.progressValue * self.progressBarContainerWidth
                    }
                    .onChange(of: geometryReader.size, perform: { newValue in
                        self.progressBarContainerWidth = newValue.width
                        self.progressBarWidth = self.progressValue * self.progressBarContainerWidth
                    })
                }
            }
            .offset(y: (Double(self.height) * self.scaleFactorOnDrag - self.height) / 2)
        }
        .frame(maxHeight: Double(self.height) * self.scaleFactorOnDrag)
        .onChange(of: self.progressValue, perform: { newValue in
            self.progressBarWidth = newValue * self.progressBarContainerWidth
        })
    }
}

struct HorizontalProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalProgressBarView(progressValue: .constant(0.5), foregroundColor: .blue, onDragging: { value in
            print("onDragging, value", value)
        }, onDraggingEnded: { value in
            print("onDraggingEnded, value", value)
        }).padding(30).background(Color.black)
    }
}
