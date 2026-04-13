import AppKit
import Foundation

struct IconSpec {
    let filename: String
    let size: CGFloat
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ".")

let specs: [IconSpec] = [
    .init(filename: "Icon-20@2x.png", size: 40),
    .init(filename: "Icon-20@3x.png", size: 60),
    .init(filename: "Icon-29@2x.png", size: 58),
    .init(filename: "Icon-29@3x.png", size: 87),
    .init(filename: "Icon-40@2x.png", size: 80),
    .init(filename: "Icon-40@3x.png", size: 120),
    .init(filename: "Icon-60@2x.png", size: 120),
    .init(filename: "Icon-60@3x.png", size: 180),
    .init(filename: "Icon-20~ipad.png", size: 20),
    .init(filename: "Icon-20@2x~ipad.png", size: 40),
    .init(filename: "Icon-29~ipad.png", size: 29),
    .init(filename: "Icon-29@2x~ipad.png", size: 58),
    .init(filename: "Icon-40~ipad.png", size: 40),
    .init(filename: "Icon-40@2x~ipad.png", size: 80),
    .init(filename: "Icon-76.png", size: 76),
    .init(filename: "Icon-76@2x.png", size: 152),
    .init(filename: "Icon-83.5@2x.png", size: 167),
    .init(filename: "Icon-1024.png", size: 1024),
]

func makeImage(side: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: side, height: side))
    image.lockFocus()

    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        NSColor(calibratedRed: 0.98, green: 0.71, blue: 0.12, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.95, green: 0.47, blue: 0.16, alpha: 1.0).cgColor
    ] as CFArray
    let locations: [CGFloat] = [0.0, 1.0]
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: side * 0.12, y: side),
            end: CGPoint(x: side * 0.88, y: 0),
            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
        )
    }

    context.saveGState()
    context.setFillColor(NSColor(calibratedRed: 0.86, green: 0.38, blue: 0.12, alpha: 0.16).cgColor)
    context.fillEllipse(in: CGRect(x: -side * 0.12, y: -side * 0.08, width: side * 0.78, height: side * 0.48))
    context.restoreGState()

    context.saveGState()
    let haloRect = CGRect(x: side * 0.08, y: side * 0.52, width: side * 0.84, height: side * 0.34)
    context.setFillColor(NSColor.white.withAlphaComponent(0.12).cgColor)
    context.fillEllipse(in: haloRect)
    context.restoreGState()

    let shieldRect = CGRect(x: side * 0.22, y: side * 0.2, width: side * 0.56, height: side * 0.6)
    let shieldPath = CGMutablePath()
    shieldPath.move(to: CGPoint(x: shieldRect.minX + shieldRect.width * 0.5, y: shieldRect.maxY))
    shieldPath.addCurve(
        to: CGPoint(x: shieldRect.maxX, y: shieldRect.maxY - shieldRect.height * 0.2),
        control1: CGPoint(x: shieldRect.minX + shieldRect.width * 0.72, y: shieldRect.maxY),
        control2: CGPoint(x: shieldRect.maxX, y: shieldRect.maxY - shieldRect.height * 0.04)
    )
    shieldPath.addLine(to: CGPoint(x: shieldRect.maxX, y: shieldRect.minY + shieldRect.height * 0.44))
    shieldPath.addCurve(
        to: CGPoint(x: shieldRect.midX, y: shieldRect.minY),
        control1: CGPoint(x: shieldRect.maxX, y: shieldRect.minY + shieldRect.height * 0.2),
        control2: CGPoint(x: shieldRect.midX + shieldRect.width * 0.16, y: shieldRect.minY + shieldRect.height * 0.06)
    )
    shieldPath.addCurve(
        to: CGPoint(x: shieldRect.minX, y: shieldRect.minY + shieldRect.height * 0.44),
        control1: CGPoint(x: shieldRect.midX - shieldRect.width * 0.16, y: shieldRect.minY + shieldRect.height * 0.06),
        control2: CGPoint(x: shieldRect.minX, y: shieldRect.minY + shieldRect.height * 0.2)
    )
    shieldPath.addLine(to: CGPoint(x: shieldRect.minX, y: shieldRect.maxY - shieldRect.height * 0.2))
    shieldPath.addCurve(
        to: CGPoint(x: shieldRect.midX, y: shieldRect.maxY),
        control1: CGPoint(x: shieldRect.minX, y: shieldRect.maxY - shieldRect.height * 0.04),
        control2: CGPoint(x: shieldRect.minX + shieldRect.width * 0.28, y: shieldRect.maxY)
    )
    shieldPath.closeSubpath()

    context.saveGState()
    context.addPath(shieldPath)
    context.setShadow(
        offset: CGSize(width: 0, height: -side * 0.01),
        blur: side * 0.06,
        color: NSColor.black.withAlphaComponent(0.18).cgColor
    )
    context.setFillColor(NSColor.white.withAlphaComponent(0.96).cgColor)
    context.fillPath()
    context.restoreGState()

    context.saveGState()
    context.translateBy(x: side * 0.51, y: side * 0.53)
    context.rotate(by: -.pi / 14)
    let flagPath = CGMutablePath()
    flagPath.move(to: CGPoint(x: -side * 0.16, y: side * 0.14))
    flagPath.addLine(to: CGPoint(x: -side * 0.16, y: -side * 0.14))
    context.setStrokeColor(NSColor(calibratedRed: 0.85, green: 0.42, blue: 0.12, alpha: 1.0).cgColor)
    context.setLineWidth(side * 0.045)
    context.setLineCap(.round)
    context.addPath(flagPath)
    context.strokePath()

    let pennant = CGMutablePath()
    pennant.move(to: CGPoint(x: -side * 0.14, y: side * 0.12))
    pennant.addCurve(
        to: CGPoint(x: side * 0.12, y: side * 0.045),
        control1: CGPoint(x: -side * 0.01, y: side * 0.15),
        control2: CGPoint(x: side * 0.07, y: side * 0.12)
    )
    pennant.addCurve(
        to: CGPoint(x: -side * 0.14, y: -side * 0.025),
        control1: CGPoint(x: side * 0.07, y: -side * 0.01),
        control2: CGPoint(x: -side * 0.02, y: side * 0.005)
    )
    pennant.closeSubpath()
    context.addPath(pennant)
    context.setFillColor(NSColor(calibratedRed: 0.96, green: 0.55, blue: 0.16, alpha: 1.0).cgColor)
    context.fillPath()
    context.restoreGState()

    context.saveGState()
    context.setStrokeColor(NSColor(calibratedRed: 0.15, green: 0.62, blue: 0.35, alpha: 1.0).cgColor)
    context.setLineWidth(side * 0.075)
    context.setLineCap(.round)
    context.setLineJoin(.round)
    let checkmark = CGMutablePath()
    checkmark.move(to: CGPoint(x: side * 0.39, y: side * 0.41))
    checkmark.addLine(to: CGPoint(x: side * 0.49, y: side * 0.31))
    checkmark.addLine(to: CGPoint(x: side * 0.66, y: side * 0.52))
    context.addPath(checkmark)
    context.strokePath()
    context.restoreGState()

    image.unlockFocus()
    return image
}

func save(_ image: NSImage, to url: URL) throws {
    guard
        let tiff = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let pngData = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "IconGeneration", code: 1)
    }
    try pngData.write(to: url)
}

try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

for spec in specs {
    let image = makeImage(side: spec.size)
    try save(image, to: outputDirectory.appendingPathComponent(spec.filename))
    print("Generated \(spec.filename)")
}
