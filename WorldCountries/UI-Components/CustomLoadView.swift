//
//  CustomLoadView.swift
//  WorldCountries
//

import SwiftUI

/// A self-contained loading animation: a slowly spinning wireframe globe
/// circled by an orbiting satellite, wrapped in a breathing halo and paired
/// with a caption whose dots pulse in sequence.
///
/// The whole animation is driven by a single `TimelineView`, so it stays in
/// sync and stops as soon as `isLoading` becomes `false`. People who prefer
/// reduced motion get a calm, static frame instead.
struct CustomLoadView: View {
    /// Kept for call-site compatibility; the animation runs while `true`.
    var isLoading: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0,
                                paused: !isLoading || reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate

            VStack(spacing: 16) {
                GlobeOrbitView(time: time)
                    .frame(width: 164, height: 164)

                LoadingCaption(time: time)
            }
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.94)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Globe with orbiting satellite

private struct GlobeOrbitView: View {
    let time: Double

    private let accent = Color("OnButton")
    private let orbitColor = Color("GrayText")

    var body: some View {
        Canvas { context, size in
            draw(in: &context, size: size)
        }
        .accessibilityHidden(true)
    }

    private func draw(in context: inout GraphicsContext, size: CGSize) {
        let side = min(size.width, size.height)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        // Gentle breathing so the globe never looks completely frozen.
        let breath = 0.5 + 0.5 * sin(time * 2 * Double.pi / 2.8)
        let globeRadius = side * 0.20 * (1 + 0.02 * CGFloat(breath))

        drawHalo(in: &context, center: center, radius: globeRadius, breath: breath)

        let spin = time * 2 * Double.pi / 7.5
        drawGlobe(in: &context, center: center, radius: globeRadius, spin: spin)

        let orbit = Orbit(center: center,
                          radiusX: globeRadius * 1.95,
                          radiusY: globeRadius * 1.38,
                          tilt: CGFloat(-16) * .pi / 180)
        drawOrbit(in: &context, orbit: orbit)

        // One full revolution every 3.6 seconds.
        let satellitePhase = time * 2 * Double.pi / 3.6
        drawSatellite(in: &context, orbit: orbit, phase: satellitePhase)
    }

    private func drawHalo(in context: inout GraphicsContext,
                          center: CGPoint,
                          radius: CGFloat,
                          breath: Double) {
        let haloRadius = radius * (1.5 + 0.22 * CGFloat(breath))
        let rect = CGRect(x: center.x - haloRadius,
                          y: center.y - haloRadius,
                          width: haloRadius * 2,
                          height: haloRadius * 2)

        context.fill(Path(ellipseIn: rect), with: .radialGradient(
            Gradient(stops: [
                .init(color: accent.opacity(0.20 + 0.10 * (1 - breath)), location: 0),
                .init(color: accent.opacity(0.07), location: 0.55),
                .init(color: accent.opacity(0), location: 1)
            ]),
            center: center,
            startRadius: radius * 0.4,
            endRadius: haloRadius))
    }

    private func drawGlobe(in context: inout GraphicsContext,
                           center: CGPoint,
                           radius: CGFloat,
                           spin: Double) {
        let rect = CGRect(x: center.x - radius,
                          y: center.y - radius,
                          width: radius * 2,
                          height: radius * 2)
        let circle = Path(ellipseIn: rect)

        // Soft atmosphere around the sphere.
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: radius * 0.22))
            layer.fill(circle, with: .color(accent.opacity(0.35)))
        }

        // Sphere body: a warm, translucent ball.
        context.fill(circle, with: .radialGradient(
            Gradient(stops: [
                .init(color: accent.opacity(0.30), location: 0),
                .init(color: accent.opacity(0.12), location: 0.72),
                .init(color: accent.opacity(0.05), location: 1)
            ]),
            center: CGPoint(x: center.x - radius * 0.35, y: center.y - radius * 0.35),
            startRadius: 0,
            endRadius: radius * 1.4))

        context.drawLayer { layer in
            layer.clip(to: circle)

            let lineColor = accent.opacity(0.78)
            let meridianCount = 8

            // Longitudes. Their width follows |cos|, which reads as a sphere
            // rotating around its vertical axis.
            for index in 0..<meridianCount {
                let angle = spin + Double(index) * .pi / Double(meridianCount)
                let rx = max(radius * CGFloat(abs(cos(angle))), 0.6)
                let meridianRect = CGRect(x: center.x - rx,
                                          y: center.y - radius,
                                          width: rx * 2,
                                          height: radius * 2)
                layer.stroke(Path(ellipseIn: meridianRect),
                             with: .color(lineColor),
                             lineWidth: 1)
            }

            // Latitudes.
            for latitude in [-60.0, -30.0, 0.0, 30.0, 60.0] {
                let radians = latitude * .pi / 180
                let y = center.y + radius * CGFloat(sin(radians))
                let rx = radius * CGFloat(cos(radians))
                let ry = rx * 0.2
                let latitudeRect = CGRect(x: center.x - rx,
                                          y: y - ry,
                                          width: rx * 2,
                                          height: ry * 2)
                layer.stroke(Path(ellipseIn: latitudeRect),
                             with: .color(lineColor.opacity(0.55)),
                             lineWidth: 0.9)
            }

            // Light from the top-left, shade toward the bottom-right.
            layer.fill(circle, with: .linearGradient(
                Gradient(stops: [
                    .init(color: .white.opacity(0.18), location: 0),
                    .init(color: .clear, location: 0.45),
                    .init(color: .black.opacity(0.22), location: 1)
                ]),
                startPoint: CGPoint(x: center.x - radius, y: center.y - radius),
                endPoint: CGPoint(x: center.x + radius, y: center.y + radius)))
        }

        // Rim light.
        context.stroke(circle, with: .color(accent.opacity(0.85)), lineWidth: 1.2)
    }

    private func drawOrbit(in context: inout GraphicsContext, orbit: Orbit) {
        context.stroke(orbit.path,
                       with: .color(orbitColor.opacity(0.28)),
                       style: StrokeStyle(lineWidth: 1, lineCap: .round))
    }

    private func drawSatellite(in context: inout GraphicsContext,
                               orbit: Orbit,
                               phase: Double) {
        // A fading comet-like trail behind the satellite.
        let trailSpan = 1.1
        let segmentCount = 22
        for index in 0..<segmentCount {
            let start = phase - trailSpan * Double(index) / Double(segmentCount)
            let end = phase - trailSpan * Double(index + 1) / Double(segmentCount)
            var segment = Path()
            segment.move(to: orbit.point(at: start))
            segment.addLine(to: orbit.point(at: end))

            let strength = 1 - Double(index) / Double(segmentCount)
            let front = (orbit.depth(at: start) + 1) / 2
            context.stroke(segment,
                           with: .color(accent.opacity(0.55 * strength * strength * (0.35 + 0.65 * front))),
                           style: StrokeStyle(lineWidth: 0.8 + 2 * strength, lineCap: .round))
        }

        let head = orbit.point(at: phase)
        let front = (orbit.depth(at: phase) + 1) / 2
        let headRadius = 3.4 + 1.8 * front
        let headRect = CGRect(x: head.x - headRadius,
                              y: head.y - headRadius,
                              width: headRadius * 2,
                              height: headRadius * 2)

        // Glow.
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: headRadius * 1.3))
            layer.fill(Path(ellipseIn: headRect),
                       with: .color(accent.opacity(0.35 + 0.35 * front)))
        }

        // Body with a small specular highlight.
        context.fill(Path(ellipseIn: headRect), with: .color(accent))
        let highlightRadius = headRadius * 0.42
        let highlightRect = CGRect(x: head.x - headRadius * 0.45 - highlightRadius,
                                   y: head.y - headRadius * 0.5 - highlightRadius,
                                   width: highlightRadius * 2,
                                   height: highlightRadius * 2)
        context.fill(Path(ellipseIn: highlightRect), with: .color(.white.opacity(0.9)))
    }
}

// MARK: - Caption

private struct LoadingCaption: View {
    let time: Double

    private let textColor = Color("GrayText")

    var body: some View {
        HStack(spacing: 6) {
            Text("loading".localized)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(textColor)

            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(textColor)
                        .frame(width: 3.5, height: 3.5)
                        .opacity(dotOpacity(at: index))
                }
            }
            .offset(y: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("loading".localized)
    }

    private func dotOpacity(at index: Int) -> Double {
        let phase = time * 0.9 - Double(index) * 0.22
        let wave = 0.5 + 0.5 * sin(phase * 2 * .pi)
        return 0.18 + 0.82 * wave
    }
}

// MARK: - Orbit geometry

/// An ellipse in the screen plane, rotated by `tilt`, that a satellite travels
/// along. Sampling points keeps the motion exact and avoids transform ordering
/// surprises.
private struct Orbit {
    let center: CGPoint
    let radiusX: CGFloat
    let radiusY: CGFloat
    let tilt: CGFloat

    func point(at phase: Double) -> CGPoint {
        let localX = radiusX * CGFloat(sin(phase))
        let localY = -radiusY * CGFloat(cos(phase))
        let cosTilt = cos(tilt)
        let sinTilt = sin(tilt)
        return CGPoint(x: center.x + localX * cosTilt - localY * sinTilt,
                       y: center.y + localX * sinTilt + localY * cosTilt)
    }

    /// `1` when the satellite is closest to the viewer, `-1` when farthest.
    func depth(at phase: Double) -> Double {
        cos(phase)
    }

    var path: Path {
        var path = Path()
        let sampleCount = 160
        for index in 0...sampleCount {
            let phase = Double(index) / Double(sampleCount) * 2 * .pi
            let point = self.point(at: phase)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

#if DEBUG
struct CustomLoadView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CustomLoadView()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.light)

            CustomLoadView()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}
#endif
