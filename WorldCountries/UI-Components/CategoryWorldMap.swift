import ImageIO
import SwiftUI
import UIKit

struct CategoryWorldMap: UIViewRepresentable {
    let selectedIDs: Set<String>
    let tappableIDs: Set<String>
    let colorRGB: Int32
    let onDoubleTap: () -> Void
    let onTap: (String) -> Void

    func makeUIView(context: Context) -> WorldMapScrollView {
        WorldMapScrollView()
    }

    func updateUIView(_ view: WorldMapScrollView, context: Context) {
        view.update(
            selectedIDs: selectedIDs, tappableIDs: tappableIDs, colorRGB: colorRGB,
            onDoubleTap: onDoubleTap, onTap: onTap
        )
    }
}

final class WorldMapScrollView: UIScrollView, UIScrollViewDelegate {
    private let picture = UIImageView()
    private let map = WorldMapRaster.shared
    private var fittedSize = CGSize.zero
    private var paintedRegions: Set<Int>?
    private var paintedColor: Int32?
    private var tappableIDs: Set<String> = []
    private var onDoubleTap: (() -> Void)?
    private var onTap: ((String) -> Void)?

    init() {
        super.init(frame: .zero)
        delegate = self
        backgroundColor = .white
        minimumZoomScale = 1
        maximumZoomScale = 12
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        picture.isUserInteractionEnabled = true
        picture.isAccessibilityElement = true
        picture.accessibilityTraits = .image
        picture.accessibilityLabel = "category_world_map".localized

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(zoomIntoMap(_:)))
        doubleTap.numberOfTapsRequired = 2
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(selectCountry(_:)))
        singleTap.require(toFail: doubleTap)
        picture.addGestureRecognizer(doubleTap)
        picture.addGestureRecognizer(singleTap)
        addSubview(picture)
    }

    required init?(coder: NSCoder) { return nil }

    func update(
        selectedIDs: Set<String>, tappableIDs: Set<String>, colorRGB: Int32,
        onDoubleTap: @escaping () -> Void, onTap: @escaping (String) -> Void
    ) {
        self.tappableIDs = tappableIDs
        self.onDoubleTap = onDoubleTap
        self.onTap = onTap
        guard let map else { return }

        let regions = map.regions(matching: selectedIDs)
        guard regions != paintedRegions || colorRGB != paintedColor else { return }
        picture.image = map.image(highlighting: regions, colorRGB: colorRGB)
        paintedRegions = regions
        paintedColor = colorRGB
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = bounds.size
        guard let map, size != fittedSize, size.width > 0, size.height > 0 else { return }

        fittedSize = size
        setZoomScale(minimumZoomScale, animated: false)
        let scale = min(size.width / CGFloat(map.width), size.height / CGFloat(map.height))
        let imageSize = CGSize(width: CGFloat(map.width) * scale, height: CGFloat(map.height) * scale)
        picture.frame = CGRect(origin: .zero, size: imageSize)
        contentSize = imageSize
        centerPicture()
        contentOffset = CGPoint(x: -contentInset.left, y: -contentInset.top)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? { picture }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerPicture()
    }

    private func centerPicture() {
        let horizontal = max(0, (bounds.width - contentSize.width) / 2)
        let vertical = max(0, (bounds.height - contentSize.height) / 2)
        contentInset = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    @objc private func zoomIntoMap(_ recognizer: UITapGestureRecognizer) {
        guard picture.image != nil, bounds.width > 0, bounds.height > 0 else { return }
        let point = recognizer.location(in: picture)
        let targetScale = min(maximumZoomScale, max(2.5, zoomScale * 2))
        let width = bounds.width / targetScale
        let height = bounds.height / targetScale
        let x = min(max(0, point.x - width / 2), max(0, picture.bounds.width - width))
        let y = min(max(0, point.y - height / 2), max(0, picture.bounds.height - height))

        onDoubleTap?()
        zoom(to: CGRect(x: x, y: y, width: width, height: height), animated: true)
    }

    @objc private func selectCountry(_ recognizer: UITapGestureRecognizer) {
        guard let map, picture.bounds.width > 0, picture.bounds.height > 0 else { return }
        let point = recognizer.location(in: picture)
        if let id = map.countryID(
            x: point.x / picture.bounds.width,
            y: point.y / picture.bounds.height,
            among: tappableIDs
        ) {
            onTap?(id)
        }
    }
}

private struct WorldMapRaster {
    static let shared = WorldMapRaster()
    private static let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private static let layout = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue

    let width: Int
    let height: Int
    private let base: CGImage
    private let basePixels: [UInt8]
    private let indices: [UInt16]
    private let countryIDs: [[String]]
    private let runs: [[Range<Int>]]

    private init?() {
        guard let base = Self.loadPNG("WorldMap"),
              let mask = Self.loadPNG("CountryRegions"),
              base.width == mask.width, base.height == mask.height,
              let basePixels = Self.pixels(in: base),
              let maskPixels = Self.pixels(in: mask),
              let lookupURL = Bundle.main.url(forResource: "CountryRegions", withExtension: "json", subdirectory: "CategoryMap"),
              let data = try? Data(contentsOf: lookupURL),
              let countryIDs = try? JSONDecoder().decode([[String]].self, from: data),
              !countryIDs.isEmpty else { return nil }

        self.width = base.width
        self.height = base.height
        self.base = base
        self.basePixels = basePixels
        self.countryIDs = countryIDs

        var indices = [UInt16]()
        indices.reserveCapacity(base.width * base.height)
        var runs = [[Range<Int>]](repeating: [], count: countryIDs.count)
        var start = 0
        var current = 0
        for offset in stride(from: 0, to: maskPixels.count, by: 4) {
            let index = Int(maskPixels[offset]) | (Int(maskPixels[offset + 1]) << 8)
            guard index < countryIDs.count else { return nil }
            indices.append(UInt16(index))
            if index != current {
                if current != 0 { runs[current].append(start..<offset) }
                current = index
                start = offset
            }
        }
        if current != 0 { runs[current].append(start..<maskPixels.count) }
        self.indices = indices
        self.runs = runs
    }

    func regions(matching selectedIDs: Set<String>) -> Set<Int> {
        Set(countryIDs.indices.dropFirst().filter { index in
            countryIDs[index].contains(where: selectedIDs.contains)
        })
    }

    func countryID(x: CGFloat, y: CGFloat, among availableIDs: Set<String>) -> String? {
        guard x >= 0, x < 1, y >= 0, y < 1 else { return nil }
        let column = Int(x * CGFloat(width))
        let row = Int(y * CGFloat(height))
        return countryIDs[Int(indices[row * width + column])].first(where: availableIDs.contains)
    }

    func image(highlighting regions: Set<Int>, colorRGB: Int32) -> UIImage {
        guard !regions.isEmpty else { return UIImage(cgImage: base) }

        // Preserve the white border pixels and their antialiasing when tinting black land.
        let red = Int((colorRGB >> 16) & 255)
        let green = Int((colorRGB >> 8) & 255)
        let blue = Int(colorRGB & 255)
        var shades: [(UInt8, UInt8, UInt8)] = []
        shades.reserveCapacity(256)
        for white in 0...255 {
            let redShade = UInt8(red + (255 - red) * white / 255)
            let greenShade = UInt8(green + (255 - green) * white / 255)
            let blueShade = UInt8(blue + (255 - blue) * white / 255)
            shades.append((redShade, greenShade, blueShade))
        }

        var pixels = basePixels
        for region in regions {
            for run in runs[region] {
                for offset in stride(from: run.lowerBound, to: run.upperBound, by: 4) {
                    let (r, g, b) = shades[Int(basePixels[offset])]
                    pixels[offset] = r
                    pixels[offset + 1] = g
                    pixels[offset + 2] = b
                }
            }
        }
        guard let provider = CGDataProvider(data: Data(pixels) as CFData),
              let image = CGImage(
                width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32,
                bytesPerRow: width * 4, space: Self.colorSpace,
                bitmapInfo: CGBitmapInfo(rawValue: Self.layout),
                provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent
              ) else { return UIImage(cgImage: base) }
        return UIImage(cgImage: image)
    }

    private static func loadPNG(_ name: String) -> CGImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "CategoryMap"),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }

    private static func pixels(in image: CGImage) -> [UInt8]? {
        var pixels = [UInt8](repeating: 0, count: image.width * image.height * 4)
        let rendered = pixels.withUnsafeMutableBytes { bytes -> Bool in
            guard let context = CGContext(
                data: bytes.baseAddress, width: image.width, height: image.height,
                bitsPerComponent: 8, bytesPerRow: image.width * 4, space: colorSpace, bitmapInfo: layout
            ) else { return false }
            context.interpolationQuality = .none
            context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
            return true
        }
        return rendered ? pixels : nil
    }
}
