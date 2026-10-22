// Composes authentic screenshots with a native AppKit editorial layout.
// Usage: swift tools/compose_store_screenshots.swift <artifact-root>
import AppKit
import Foundation

let root = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "artifacts/app-store/2026-10-22")
let fm = FileManager.default
let ink = NSColor(calibratedRed: 0.24, green: 0.17, blue: 0.13, alpha: 1)
let muted = NSColor(calibratedRed: 0.49, green: 0.38, blue: 0.31, alpha: 1)
let accent = NSColor(calibratedRed: 0.88, green: 0.36, blue: 0.12, alpha: 1)

struct Slide {
    let file: String
    let zhTitle: String
    let enTitle: String
    let zhSubtitle: String
    let enSubtitle: String
}
let slides = [
    Slide(file: "01-today", zhTitle: "今天，从一小步开始", enTitle: "Small steps.\nA better today.", zhSubtitle: "今日清单，让行动清晰一点", enSubtitle: "A clear daily list. A little less friction."),
    Slide(file: "02-goals", zhTitle: "把大目标，变成小行动", enTitle: "Big goals.\nSmall beginnings.", zhSubtitle: "阅读、运动、学习，各有自己的节奏", enSubtitle: "Make room for reading, movement, and learning."),
    Slide(file: "03-stats", zhTitle: "每一次坚持，都看得见", enTitle: "See how far\nyou've come.", zhSubtitle: "记录完成，也记住你的保底努力", enSubtitle: "Full effort or a small win. Both count."),
    Slide(file: "04-themes", zhTitle: "换个心情，继续坚持", enTitle: "Your goals.\nYour colors.", zhSubtitle: "多套外观主题，找到喜欢的日常", enSubtitle: "A palette that feels like you."),
]

func text(_ string: String, rect: NSRect, size: CGFloat, weight: NSFont.Weight, color: NSColor, center: Bool = false) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = center ? .center : .left
    paragraph.lineSpacing = size * 0.14
    paragraph.lineBreakMode = .byWordWrapping
    let font = NSFont.systemFont(ofSize: size, weight: weight)
    (string as NSString).draw(in: rect, withAttributes: [.font: font, .foregroundColor: color, .paragraphStyle: paragraph])
}

func saveRGB(_ image: NSImage, width: Int, height: Int, url: URL) throws {
    var sourceRect = NSRect(x: 0, y: 0, width: width, height: height)
    guard let source = image.cgImage(forProposedRect: &sourceRect, context: nil, hints: nil),
          let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { fatalError("Image context failed") }
    context.interpolationQuality = .high
    context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
    let png = NSBitmapImageRep(cgImage: context.makeImage()!).representation(using: .png, properties: [:])!
    try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try png.write(to: url)
}

func compose(slide: Slide, index: Int, language: String, device: String) throws -> NSImage {
    let ipad = device == "ipad"
    let english = language == "en"
    let w: CGFloat = ipad ? 2064 : 1320
    let h: CGFloat = ipad ? 2752 : 2868
    let screenshotURL = root.appendingPathComponent("raw/\(language)/\(device)/\(slide.file).png")
    guard let screenshot = NSImage(contentsOf: screenshotURL) else { fatalError("Missing \(screenshotURL.path)") }
    let image = NSImage(size: NSSize(width: w, height: h))
    image.lockFocusFlipped(true)
    let bounds = NSRect(x: 0, y: 0, width: w, height: h)
    let gradient = NSGradient(starting: NSColor(calibratedRed: 1, green: 0.98, blue: 0.94, alpha: 1), ending: NSColor(calibratedRed: 1, green: 0.85, blue: 0.67, alpha: 1))!
    gradient.draw(in: bounds, angle: 65)
    NSColor.white.withAlphaComponent(0.28).setFill()
    NSBezierPath(ovalIn: NSRect(x: -w * 0.26, y: h * 0.62, width: w * 1.13, height: w * 1.13)).fill()
    NSColor(calibratedRed: 1, green: 0.71, blue: 0.33, alpha: 0.12).setFill()
    NSBezierPath(ovalIn: NSRect(x: w * 0.65, y: -w * 0.22, width: w * 0.8, height: w * 0.8)).fill()

    let margin: CGFloat = ipad ? 170 : 105
    let brandY: CGFloat = ipad ? 64 : 74
    let iconSide: CGFloat = ipad ? 64 : 58
    if let icon = NSImage(contentsOfFile: "LazyButNot/Assets.xcassets/AppIcon.appiconset/Icon-1024.png") {
        NSGraphicsContext.saveGraphicsState()
        let iconRect = NSRect(x: margin, y: brandY, width: iconSide, height: iconSide)
        NSBezierPath(roundedRect: iconRect, xRadius: 14, yRadius: 14).addClip()
        icon.draw(in: iconRect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
        NSGraphicsContext.restoreGraphicsState()
    }
    text(english ? "LazyButNot" : "懒人不懒", rect: NSRect(x: margin + iconSide + 20, y: brandY + 8, width: 600, height: 60), size: ipad ? 34 : 32, weight: .semibold, color: ink)
    text(String(format: "%02d / 04", index + 1), rect: NSRect(x: w - margin - 175, y: brandY + 12, width: 175, height: 50), size: 27, weight: .medium, color: muted)

    let titleY: CGFloat = ipad ? 163 : 184
    let titleHeight: CGFloat = english ? (ipad ? 260 : 285) : (ipad ? 125 : 155)
    text(english ? slide.enTitle : slide.zhTitle, rect: NSRect(x: margin, y: titleY, width: w - margin * 2, height: titleHeight), size: ipad ? (english ? 92 : 98) : (english ? 105 : 85), weight: .bold, color: ink)
    let subY: CGFloat = english ? (ipad ? 414 : 458) : (ipad ? 306 : 362)
    text(english ? slide.enSubtitle : slide.zhSubtitle, rect: NSRect(x: margin, y: subY, width: w - margin * 2, height: 94), size: ipad ? 38 : 34, weight: .regular, color: muted)

    let screenWidth: CGFloat = ipad ? 1535 : 966
    let screenHeight = screenWidth * (ipad ? 2752.0 / 2064.0 : 2868.0 / 1320.0)
    let top: CGFloat = ipad ? 550 : 600
    let screenRect = NSRect(x: (w - screenWidth) / 2, y: top, width: screenWidth, height: screenHeight)
    let bezel: CGFloat = ipad ? 22 : 16
    let frame = screenRect.insetBy(dx: -bezel, dy: -bezel)
    let radius: CGFloat = ipad ? 48 : 96

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor(calibratedRed: 0.44, green: 0.23, blue: 0.08, alpha: 0.25)
    shadow.shadowOffset = NSSize(width: 0, height: 24)
    shadow.shadowBlurRadius = 40
    shadow.set()
    NSColor(calibratedWhite: 0.14, alpha: 1).setFill()
    NSBezierPath(roundedRect: frame, xRadius: radius + bezel, yRadius: radius + bezel).fill()
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: screenRect, xRadius: radius, yRadius: radius).addClip()
    screenshot.draw(in: screenRect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: [.interpolation: NSImageInterpolation.high])
    NSGraphicsContext.restoreGraphicsState()

    text(english ? "A little less pressure. A little more progress." : "少一点压力，多一点持续。", rect: NSRect(x: margin, y: h - 99, width: w - margin * 2, height: 56), size: ipad ? 32 : 29, weight: .medium, color: accent, center: true)
    image.unlockFocus()
    let output = root.appendingPathComponent("upload/\(language)/\(device)/\(slide.file).png")
    try saveRGB(image, width: Int(w), height: Int(h), url: output)
    print(output.path)
    return image
}

for language in ["zh-Hans", "en"] {
    for device in ["iphone", "ipad"] {
        var previews: [NSImage] = []
        for (index, slide) in slides.enumerated() {
            previews.append(try compose(slide: slide, index: index, language: language, device: device))
        }
        let pw: CGFloat = device == "iphone" ? 330 : 387
        let ph: CGFloat = device == "iphone" ? 717 : 516
        let contact = NSImage(size: NSSize(width: pw * 4, height: ph))
        contact.lockFocusFlipped(true)
        for (index, preview) in previews.enumerated() {
            preview.draw(in: NSRect(x: CGFloat(index) * pw, y: 0, width: pw, height: ph), from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
        }
        contact.unlockFocus()
        try saveRGB(contact, width: Int(pw * 4), height: Int(ph), url: root.appendingPathComponent("previews/\(language)-\(device).png"))
    }
}
