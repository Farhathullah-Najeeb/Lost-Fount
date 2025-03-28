// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerDialog extends StatefulWidget {
  final LatLng initialPosition;

  const MapPickerDialog({required this.initialPosition, super.key});

  @override
  _MapPickerDialogState createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  // ignore: unused_field
  late GoogleMapController _mapController;
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pick Location'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition,
            zoom: 15,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          onTap: (LatLng position) {
            setState(() {
              _pickedLocation = position;
            });
          },
          markers: _pickedLocation != null
              ? {
                  Marker(
                    markerId: MarkerId('picked'),
                    position: _pickedLocation!,
                  ),
                }
              : {},
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _pickedLocation != null
              ? () => Navigator.of(context).pop(_pickedLocation)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
          ),
          child: Text('Confirm', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
