import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { createCanvas } from "@napi-rs/canvas";
import { geoArea, geoNaturalEarth1, geoPath } from "d3-geo";

const source = "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/v5.1.2/geojson/ne_50m_admin_0_map_units.geojson";
const sha256 = "b8d421aca6e9e08e8cdf09cc26af111cc3e0deba4fe915611d58ade71e8a4db0";
const data = execFileSync("curl", ["--fail", "--silent", "--show-error", "--location", "--max-time", "30", source], {
    maxBuffer: 16 * 1024 * 1024,
});
if (createHash("sha256").update(data).digest("hex") !== sha256) {
    throw new Error("Natural Earth checksum mismatch");
}

const world = JSON.parse(data);
for (const { geometry } of world.features) {
    const polygons = geometry.type === "Polygon" ? [geometry.coordinates] : geometry.coordinates;
    for (const coordinates of polygons) {
        // D3 expects clockwise exterior rings for polygons smaller than a hemisphere.
        if (geoArea({ type: "Polygon", coordinates }) > 2 * Math.PI) {
            for (const ring of coordinates) ring.reverse();
        }
    }
}

// Features with the same ISO code are painted and selected as a single country.
const regions = new Map();
const features = world.features.map((feature) => {
    const p = feature.properties;
    const codes = p.GU_A3 === "NJM" ? ["SJM", "SJ"]
        : [p.ISO_A3_EH, p.ISO_A3, p.ISO_A2_EH, p.ISO_A2].filter((code) => /^[A-Z]{2,3}$/.test(code));
    const key = codes[0] ?? p.GU_A3;
    if (!regions.has(key)) {
        regions.set(key, { index: regions.size + 1, ids: new Set() });
    }
    const region = regions.get(key);
    for (const code of codes) region.ids.add(`iso:${code}`);
    if (key === "XK") region.ids.add("iso:XKX");
    if (key !== "SJM" || p.GU_A3 !== "NJM") {
        region.ids.add(`name:${p.GEOUNIT}`);
    }
    return { feature, index: region.index };
});

const width = 1920;
const padding = 12;
const projection = geoNaturalEarth1().precision(0.2).fitWidth(width - padding * 2, world);
const bounds = geoPath(projection).bounds(world);
const [x, y] = projection.translate();
projection.translate([x + padding, y - bounds[0][1] + padding]);
const height = Math.ceil(bounds[1][1] - bounds[0][1]) + padding * 2;
const featureBounds = geoPath(projection);

const base = createCanvas(width, height);
const baseContext = base.getContext("2d");
const drawBase = geoPath(projection, baseContext);
baseContext.fillStyle = "#fff";
baseContext.fillRect(0, 0, width, height);
baseContext.fillStyle = "#000";
baseContext.strokeStyle = "#fff";
baseContext.lineWidth = 1.25;
baseContext.lineJoin = "round";

const temporary = createCanvas(width, height).getContext("2d");
const drawTemporary = geoPath(projection, temporary);
const mask = createCanvas(width, height);
const maskContext = mask.getContext("2d");
const maskPixels = maskContext.createImageData(width, height);
for (let i = 3; i < maskPixels.data.length; i += 4) maskPixels.data[i] = 255;

for (const { feature, index } of features) {
    const [[x0, y0], [x1, y1]] = featureBounds.bounds(feature);
    const left = Math.max(0, Math.floor(x0));
    const top = Math.max(0, Math.floor(y0));
    const w = Math.min(width, Math.ceil(x1)) - left;
    const h = Math.min(height, Math.ceil(y1)) - top;
    if (w <= 0 || h <= 0) continue;

    temporary.clearRect(left, top, w, h);
    temporary.beginPath();
    drawTemporary(feature);
    temporary.fill("evenodd");
    const pixels = temporary.getImageData(left, top, w, h).data;
    for (let row = 0; row < h; row++) {
        for (let column = 0; column < w; column++) {
            if (pixels[(row * w + column) * 4 + 3] < 128) continue;
            const destination = ((top + row) * width + left + column) * 4;
            maskPixels.data[destination] = index & 255;
            maskPixels.data[destination + 1] = index >> 8;
        }
    }

    baseContext.beginPath();
    drawBase(feature);
    baseContext.fill("evenodd");
}

// Draw borders on top of all fills so adjoining countries share a visible line.
baseContext.beginPath();
drawBase(world);
baseContext.stroke();

// Give subpixel islands and microstates a small target near their Natural Earth label.
const pixelCounts = new Uint32Array(regions.size + 1);
function regionAt(offset) {
    return maskPixels.data[offset] | (maskPixels.data[offset + 1] << 8);
}
for (let offset = 0; offset < maskPixels.data.length; offset += 4) {
    pixelCounts[regionAt(offset)]++;
}
const paintedDots = new Set();
for (const { feature, index } of features) {
    if (pixelCounts[index] >= 9 || paintedDots.has(index)) continue;
    const { LABEL_X, LABEL_Y } = feature.properties;
    const [x, y] = projection([LABEL_X, LABEL_Y]);
    const x0 = Math.round(x);
    const y0 = Math.round(y);
    const candidates = [[0, 0], [3, 0], [-3, 0], [0, 3], [0, -3], [3, 3], [-3, -3]];
    for (const [dx, dy] of candidates) {
        const cx = x0 + dx;
        const cy = y0 + dy;
        if (cx < 1 || cy < 1 || cx >= width - 1 || cy >= height - 1) continue;
        const offsets = [];
        for (let row = cy - 1; row <= cy + 1; row++) {
            for (let column = cx - 1; column <= cx + 1; column++) {
                offsets.push((row * width + column) * 4);
            }
        }
        if (offsets.some((offset) => {
            const existing = regionAt(offset);
            return existing !== index && existing !== 0 && (pixelCounts[existing] < 9 || paintedDots.has(existing));
        })) continue;
        for (const offset of offsets) {
            maskPixels.data[offset] = index & 255;
            maskPixels.data[offset + 1] = index >> 8;
        }
        baseContext.fillRect(cx - 1, cy - 1, 3, 3);
        baseContext.strokeRect(cx - 1, cy - 1, 3, 3);
        paintedDots.add(index);
        break;
    }
}
maskContext.putImageData(maskPixels, 0, 0);

const output = process.argv[2] ?? fileURLToPath(new URL("../../WorldCountries/Resources/CategoryMap/", import.meta.url));
await mkdir(output, { recursive: true });
await Promise.all([
    writeFile(join(output, "WorldMap.png"), base.toBuffer("image/png")),
    writeFile(join(output, "CountryRegions.png"), mask.toBuffer("image/png")),
    writeFile(join(output, "CountryRegions.json"), JSON.stringify([[], ...Array.from(regions.values(), (region) => [...region.ids])]) + "\n"),
]);
console.log(`Wrote ${width}×${height} PNGs with ${regions.size} indexed regions.`);
