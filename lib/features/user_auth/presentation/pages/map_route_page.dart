import 'package:flutter/material.dart';

class MapRoutePage extends StatefulWidget {
  const MapRoutePage({super.key, required List<Map<String, dynamic>> stops, required Map<String, dynamic> bus});

  @override
  State<MapRoutePage> createState() => _MapRoutePageState();
}

class _MapRoutePageState extends State<MapRoutePage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}