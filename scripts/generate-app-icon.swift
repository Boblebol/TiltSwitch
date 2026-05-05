import AppKit
import Foundation

let outputDirectory = URL(fileURLWithPath: "TiltSwitch/Assets.xcassets/AppIcon.appiconset")
let sizes: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

func drawIcon(size: Int, outputURL: URL) throws {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let inset = CGFloat(size) * 0.06
    let iconRect = rect.insetBy(dx: inset, dy: inset)
    let radius = CGFloat(size) * 0.22

    NSColor(calibratedRed: 0.07, green: 0.08, blue: 0.1, alpha: 1).setFill()
    NSBezierPath(rect: rect).fill()

    let background = NSBezierPath(roundedRect: iconRect, xRadius: radius, yRadius: radius)
    NSColor(calibratedRed: 0.47, green: 0.9, blue: 0.78, alpha: 1).setFill()
    background.fill()

    let accent = NSBezierPath()
    accent.move(to: NSPoint(x: iconRect.minX, y: iconRect.maxY - CGFloat(size) * 0.22))
    accent.line(to: NSPoint(x: iconRect.maxX, y: iconRect.maxY - CGFloat(size) * 0.05))
    accent.line(to: NSPoint(x: iconRect.maxX, y: iconRect.maxY))
    accent.line(to: NSPoint(x: iconRect.minX, y: iconRect.maxY))
    accent.close()
    NSColor(calibratedRed: 1, green: 0.49, blue: 0.43, alpha: 1).setFill()
    accent.fill()

    let goldDotRect = NSRect(
        x: iconRect.maxX - CGFloat(size) * 0.27,
        y: iconRect.minY + CGFloat(size) * 0.12,
        width: CGFloat(size) * 0.13,
        height: CGFloat(size) * 0.13
    )
    NSColor(calibratedRed: 1, green: 0.82, blue: 0.4, alpha: 1).setFill()
    NSBezierPath(ovalIn: goldDotRect).fill()

    let faceSize = CGFloat(size) * 0.48
    let faceRect = NSRect(
        x: rect.midX - faceSize / 2,
        y: rect.midY - faceSize / 2 + CGFloat(size) * 0.03,
        width: faceSize,
        height: faceSize
    )

    let transform = NSAffineTransform()
    transform.translateX(by: faceRect.midX, yBy: faceRect.midY)
    transform.rotate(byDegrees: -10)
    transform.translateX(by: -faceRect.midX, yBy: -faceRect.midY)
    transform.concat()

    NSColor(calibratedRed: 1, green: 0.72, blue: 0.55, alpha: 1).setFill()
    NSBezierPath(ovalIn: faceRect).fill()

    NSColor(calibratedRed: 0.08, green: 0.08, blue: 0.08, alpha: 1).setFill()
    let eyeSize = CGFloat(size) * 0.045
    NSBezierPath(ovalIn: NSRect(
        x: faceRect.minX + faceSize * 0.31,
        y: faceRect.midY + faceSize * 0.1,
        width: eyeSize,
        height: eyeSize
    )).fill()
    NSBezierPath(ovalIn: NSRect(
        x: faceRect.maxX - faceSize * 0.31 - eyeSize,
        y: faceRect.midY + faceSize * 0.1,
        width: eyeSize,
        height: eyeSize
    )).fill()

    let smile = NSBezierPath()
    smile.move(to: NSPoint(x: faceRect.minX + faceSize * 0.34, y: faceRect.midY - faceSize * 0.16))
    smile.curve(
        to: NSPoint(x: faceRect.maxX - faceSize * 0.34, y: faceRect.midY - faceSize * 0.16),
        controlPoint1: NSPoint(x: faceRect.midX - faceSize * 0.12, y: faceRect.midY - faceSize * 0.31),
        controlPoint2: NSPoint(x: faceRect.midX + faceSize * 0.12, y: faceRect.midY - faceSize * 0.31)
    )
    smile.lineWidth = max(1.4, CGFloat(size) * 0.018)
    NSColor(calibratedRed: 0.08, green: 0.08, blue: 0.08, alpha: 1).setStroke()
    smile.stroke()

    transform.invert()
    transform.concat()

    let arrowAttributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: CGFloat(size) * 0.16, weight: .black),
        .foregroundColor: NSColor(calibratedRed: 0.06, green: 0.09, blue: 0.09, alpha: 0.72)
    ]
    let arrows = "<  >" as NSString
    let arrowSize = arrows.size(withAttributes: arrowAttributes)
    arrows.draw(
        at: NSPoint(x: rect.midX - arrowSize.width / 2, y: CGFloat(size) * 0.16),
        withAttributes: arrowAttributes
    )

    image.unlockFocus()

    guard
        let tiff = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "TiltSwitchIcon", code: 1)
    }

    try png.write(to: outputURL)
}

for (filename, size) in sizes {
    try drawIcon(size: size, outputURL: outputDirectory.appendingPathComponent(filename))
}
