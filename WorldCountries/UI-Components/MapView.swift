

import SwiftUI
import MapKit


struct MapView: View {
        let latitude: Double
        let longitude: Double
    @State private var region: MKCoordinateRegion
    init(latitude: Double, longitude: Double) {

            self.latitude = latitude
            self.longitude = longitude
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
            ))
        }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [CountryLocation( coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))]) { location in
                   MapMarker(coordinate: location.coordinate, tint: .red)
               }
               .frame(height: 300)
               .cornerRadius(20)
               .padding(.bottom, 40)
    }
}

struct CountryLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
