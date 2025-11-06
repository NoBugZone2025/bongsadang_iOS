
import SwiftUI
import MapKit

struct MapView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var volunteerLocations: [VolunteerLocation]
    @Binding var selectedLocation: VolunteerLocation?
    @Binding var isParticipating: Bool

    var body: some View {
        Map(coordinateRegion: $region,
            showsUserLocation: true,
            annotationItems: volunteerLocations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                Button(action: {
                    if !isParticipating {
                        selectedLocation = location
                    }
                }) {
                    MapMarkerView(number: location.volunteerData.maxParticipants)
                }
            }
        }
        .ignoresSafeArea()
    }
}
