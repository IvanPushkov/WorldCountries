# Category map

Run `npm ci && npm run generate` from this directory with Node.js 20 or newer and curl.
The generator checks the source checksum and writes the display PNG, the
pixel-aligned region PNG, and its country lookup into the app resources.

The world outlines come from Natural Earth (public domain). The generator
projects them with [d3-geo](https://github.com/d3/d3-geo) (ISC) and rasterizes the
paths with [@napi-rs/canvas](https://github.com/Brooooooklyn/canvas) (MIT).
The app resolves each tap by reading the region index from the corresponding
pixel. Region zero is water. Subpixel territories receive a small target near their map label. Country selection and coloring work without
requests to a map service.

- [Natural Earth 1:50m map units, v5.1.2](https://github.com/nvkelso/natural-earth-vector/blob/v5.1.2/geojson/ne_50m_admin_0_map_units.geojson)
- [Natural Earth terms of use](https://www.naturalearthdata.com/about/terms-of-use/)
