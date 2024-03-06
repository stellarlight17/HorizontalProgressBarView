# Horizontal Progress Bar View

Allows customizations of height, colors, corner radius and scale factor on dragging.
Supports custom handling during dragging / when dragging ends (suitable for slider use).

Usage:
```swift
HorizontalProgressBarView(progressValue: Binding<Double>, height: CGFloat, cornerRadius: CGFloat, \
  scaleFactorOnDrag: Double, foregroundColor: Color, backgroundColor: Color, onDragging: ((Double) -> Void)?, \
  onDraggingEnded: ((Double) -> Void)?)
 ```
