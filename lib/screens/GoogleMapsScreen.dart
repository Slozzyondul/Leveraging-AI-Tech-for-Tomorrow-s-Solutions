import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Map'),
        backgroundColor: Colors.redAccent,
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0.0, 0.0), // Default location
          zoom: 2.0,
        ),
        markers: {
          const Marker(
            markerId: MarkerId('disaster1'),
            position: LatLng(-1.2921, 36.8219), // Example location
            infoWindow: InfoWindow(title: 'Flood Warning', snippet: 'Severity: High'),
          ),
          const Marker(
            markerId: MarkerId('disaster2'),
            position: LatLng(34.0522, -118.2437), // Example location
            infoWindow: InfoWindow(title: 'Wildfire Alert', snippet: 'Severity: Severe'),
          ),
        },
      ),
    );
  }
}
