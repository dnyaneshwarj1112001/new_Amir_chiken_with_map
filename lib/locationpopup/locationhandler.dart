import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationHandler {
  final Location _location = Location();

  void init(BuildContext context) async {
    // 1. Check service
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        _showLocationDialog(context);
        return;
      }
    }

    // 2. Check permission
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        _showLocationDialog(context);
        return;
      }
    }

    // 3. Safe to listen to stream ✅
    _location.onLocationChanged.listen((event) {
      debugPrint("Location: ${event.latitude}, ${event.longitude}");
    });
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Enable Location"),
        content: const Text("This app requires location. Please enable it."),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _location.requestService();
            },
            child: const Text("Enable"),
          ),
        ],
      ),
    );
  }
}
