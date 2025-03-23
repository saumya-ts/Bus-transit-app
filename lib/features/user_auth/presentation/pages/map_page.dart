import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPage extends StatefulWidget {
  final List<String> stops;

  const MapPage({super.key, required this.stops});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapboxMap _mapboxMap;
  late PointAnnotationManager _pointAnnotationManager;
  final String accessToken = "pk.eyJ1Ijoic2F5eWVkNzciLCJhIjoiY204MWMwaHUzMTY3MDJpc2F2MWNkeTJ2aiJ9.gq08bOtZCcBDkE0BfZol_g";

  @override
  Widget build(BuildContext context) {
    if (widget.stops.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No stops available")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bus Route')),
      body: MapWidget(
        onMapCreated: _onMapCreated,
        resourceOptions: ResourceOptions(
          accessToken: accessToken,
        ),
        cameraOptions: CameraOptions(
          zoom: 12.0,
        ),
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _pointAnnotationManager = await _mapboxMap.annotations.createPointAnnotationManager();

    // Ensure the stops are converted to List<String>
    List<String> stops = widget.stops.map((e) => e.toString()).toList();

    for (String stop in stops) {
      var coordinates = await _getLatLngFromPlaceName(stop);
      if (coordinates != null) {
        _addMarker({
          'name': stop,
          'longitude': coordinates[0],
          'latitude': coordinates[1],
        });
      }
    }

    _zoomToRoute();
  }

  Future<List<double>?> _getLatLngFromPlaceName(String placeName) async {
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$placeName.json?access_token=$accessToken',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'];
        if (features.isNotEmpty) {
          final coordinates = features[0]['geometry']['coordinates'];
          return [coordinates[0], coordinates[1]];
        }
      }
    } catch (e) {
      debugPrint("❌ Failed to fetch coordinates for $placeName: $e");
    }
    return null;
  }

  void _addMarker(Map stop) {
    _pointAnnotationManager.create(PointAnnotationOptions(
      geometry: Point(
        coordinates: Position(
          stop['longitude'],
          stop['latitude'],
        ),
      ).toJson(),
      textField: stop['name'] ?? '',
    ));
  }

  void _zoomToRoute() {
    _mapboxMap.flyTo(
      CameraOptions(
        zoom: 12.0,
      ),
      MapAnimationOptions(duration: 3000),
    );
  }
}
