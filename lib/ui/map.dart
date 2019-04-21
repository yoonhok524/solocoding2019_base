import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  Position position;

  MapWidget(this.position);

  @override
  State<MapWidget> createState() => MapWidgetState(position);
}

class MapWidgetState extends State<MapWidget> {
  Marker _marker;

  MapWidgetState(Position position)
      : _marker = _createMarker(position.latitude, position.longitude);

  @override
  Widget build(BuildContext context) => GoogleMap(
        onTap: (pos) {
          setState(() {
            widget.position =
                Position(latitude: pos.latitude, longitude: pos.longitude);
            _marker = _createMarker(pos.latitude, pos.longitude);
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.position.latitude, widget.position.longitude),
          zoom: 10,
        ),
        markers: Set.from([_marker]),
      );
}

Marker _createMarker(double lat, double lon) =>
    Marker(position: LatLng(lat, lon), markerId: MarkerId("$lat, $lon"));
