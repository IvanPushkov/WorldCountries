# World Countries

**World Countries** is an iOS app that lets users browse information about countries around the world. Built with **SwiftUI** using the **MVVM** architecture. Data is loaded from the **REST Countries API**.

## Key Features

### Main Screen

- Displays a list of countries as a vertical list.
- Search by country name.
- Each cell includes:
  - Country name.
  - Country flag.
  - Region (continent).

### Country Details

- Official name.
- Capital.
- Population.
- Area.
- Currency (name and symbol).
- Languages.
- Time zones.
- Coordinates displayed on a **map (MapKit)**.
- Enlarged flag. (Unicode symbols were used to optimise app loading)
- Ability to **add to favourites**.

### Favourite Countries

- A section with saved countries.
- Ability to remove from favourites.

### API Integration

- Fetching country data from the **REST Countries API**.
- Using **URLSession** for asynchronous requests.

### Local Data Storage

- Favourite countries are stored using **Core Data** / **SwiftData**.
- **Offline mode** support.

### Error Handling

- **Internet connection check**.
- **Network error** handling.
- **Alerts** on failures for a better user experience.

### Architecture

- Implemented with **MVVM**.
- Clean architecture with separated logic.

### Project Setup

The app uses no third-party libraries — to run it, you only need to:

1. Clone this repository.
2. Open the project in Xcode.

## Technologies

- **SwiftUI** — UI framework.
- **MapKit** — displaying countries on a map.
- **URLSession** — network requests.
- **Core Data** — local data storage.
- **Swift Package Manager** — dependency management.
- **REST Countries API** — data source.
