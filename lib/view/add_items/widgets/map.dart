// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

class MapPickerDialog extends StatefulWidget {
  final latlng.LatLng initialPosition;

  const MapPickerDialog({required this.initialPosition, super.key});

  @override
  _MapPickerDialogState createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late MapController _mapController;
  latlng.LatLng? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    print(
        'MapPickerDialog initialized with position: ${widget.initialPosition}');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 500,
        width: double.maxFinite,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: widget.initialPosition,
                      initialZoom: 15.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedPosition = point;
                        });
                        _mapController.move(point, 15.0);
                        print('Map tapped at: $point');
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.findme',
                      ),
                      if (_selectedPosition != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedPosition!,
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedPosition != null
                        ? 'Lat: ${_selectedPosition!.latitude.toStringAsFixed(4)}, Lng: ${_selectedPosition!.longitude.toStringAsFixed(4)}'
                        : 'Tap to select a location',
                    style: const TextStyle(fontSize: 14),
                  ),
                  ElevatedButton(
                    onPressed: _selectedPosition != null
                        ? () => Navigator.of(context).pop(_selectedPosition)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
