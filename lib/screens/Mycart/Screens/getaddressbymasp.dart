import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Getaddresslatlong extends StatefulWidget {
  const Getaddresslatlong({super.key});

  @override
  State<Getaddresslatlong> createState() => _GetaddresslatlongState();
}

class _GetaddresslatlongState extends State<Getaddresslatlong> {
  double latitude = 0.0;
  double longitude = 0.0;
  String address = '';
  bool isLoading = false;
  GoogleMapController? _mapController;

  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);

    try {
      Position position = await _determinePosition();
      latitude = position.latitude;
      longitude = position.longitude;
    

      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        address =
            "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      } else {
        address = "No address found";
      }

      // Move the map camera to the new location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(latitude, longitude),
          ),
        );
      }

      setState(() {});
    } catch (e) {
      setState(() {
        address = 'Error: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng currentLatLng = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(title: const Text("Get Current Location")),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Latitude: $latitude"),
                  Text("Longitude: $longitude"),
                  const SizedBox(height: 10),
                  Text("Address: $address"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : _getCurrentLocation,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Get Location & Address"),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentLatLng,
                zoom: 16,
              ),
              markers: latitude != 0.0
                  ? {
                      Marker(
                        markerId: const MarkerId("currentLocation"),
                        position: currentLatLng,
                        infoWindow: const InfoWindow(title: "You are here"),
                      )
                    }
                  : {},
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
