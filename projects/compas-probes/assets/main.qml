import bb.cascades 1.0

Page {
    id: root
    Container {
        layout: DockLayout {}
        MapView {
            id: mapView
            // Example default coordinates: somewhere in the USA (feel free to change)
            latitude: 37.7749   // San Francisco latitude
            longitude: -122.4194 // San Francisco longitude
            zoom: 12
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
        }
    }
}