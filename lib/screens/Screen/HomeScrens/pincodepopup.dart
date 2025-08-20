import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PincodeBottomSheet extends StatefulWidget {
  final BuildContext context;
  final Function(String) onLocationSelected;

  const PincodeBottomSheet(this.context,
      {super.key, required this.onLocationSelected});

  @override
  State<PincodeBottomSheet> createState() => _PincodeBottomSheetState();
}

class _PincodeBottomSheetState extends State<PincodeBottomSheet> {
  final TextEditingController _pincodeController = TextEditingController();
  bool isLoading = false;
  String? selectedAddress;
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  bool _isMapLoading = true;
  bool _isMapError = false;
  bool _isDisposed = false;

  List<String> previouslyAppliedPincodes = [];
  static const String _pincodesKey = 'previouslyAppliedPincodes';

  @override
  void initState() {
    super.initState();
    _loadPreviouslyAppliedPincodes();
    _initializeLocation();
  }

  Future<void> _loadPreviouslyAppliedPincodes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      previouslyAppliedPincodes = prefs.getStringList(_pincodesKey) ?? [];
    });
  }

  Future<void> _savePincode(String pincode) async {
    final prefs = await SharedPreferences.getInstance();

    if (!previouslyAppliedPincodes.contains(pincode)) {
      previouslyAppliedPincodes.insert(0, pincode);
    }

    if (previouslyAppliedPincodes.length > 4) {
      previouslyAppliedPincodes = previouslyAppliedPincodes.sublist(0, 4);
    }
    await prefs.setStringList(_pincodesKey, previouslyAppliedPincodes);
    setState(() {});
  }

  Future<void> _initializeLocation() async {
    if (_isDisposed) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!_isDisposed && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Location services are disabled. Please enable location services.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!_isDisposed && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!_isDisposed && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Location permissions are permanently denied. Please enable in settings.')),
          );
        }
        return;
      }

      await _getCurrentLocation();
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isMapError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing location: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isDisposed) return;

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 260),
      );

      if (_isDisposed || !mounted) return;

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: _selectedLocation!,
            infoWindow: const InfoWindow(
              title: 'Current Location',
            ),
          ),
        };
      });

      if (!_isDisposed) {
        _updateMapLocation(_selectedLocation!);
        await _getAddressFromLatLng(_selectedLocation!);
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isMapError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    if (_isDisposed) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (_isDisposed || !mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String? pincode = place.postalCode;

        if (pincode != null && pincode.isNotEmpty) {
          setState(() {
            _pincodeController.text = pincode;
            _markers = {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: position,
                infoWindow: InfoWindow(
                  title: 'Selected Location',
                  snippet: 'Pincode: $pincode',
                ),
              ),
            };
          });
        } else {
          if (!_isDisposed && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Could not find pincode for this location')),
            );
          }
        }
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting address: $e')),
        );
      }
    }
  }

  void _updateMapLocation(LatLng location) {
    if (_isDisposed) return;

    try {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 15,
          ),
        ),
      );
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating map: $e')),
        );
      }
    }
  }

  Widget _buildMap() {
    if (_isMapError) {
      // Close bottom sheet first
      Future.microtask(() {
        if (mounted) {
          Navigator.of(context).pop(); // 👈 closes bottom sheet
          _showLocationPopup(context);
        }
      });
      return const SizedBox
          .shrink(); // return empty widget since bottom sheet closes
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            GoogleMap(
              key: const ValueKey("pincode_google_map"),
              initialCameraPosition: CameraPosition(
                target: _selectedLocation ?? const LatLng(18.5204, 73.8567),
                zoom: 12,
              ),
              onMapCreated: (controller) {
                if (_isDisposed || !mounted) {
                  controller.dispose();
                  return;
                }
                setState(() {
                  _mapController = controller;
                  _isMapLoading = false;
                });
              },
              markers: _markers,
              onTap: (LatLng position) async {
                if (!_isDisposed) {
                  await _getAddressFromLatLng(position);
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              compassEnabled: true,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: true,
              zoomGesturesEnabled: true,
            ),
            if (_isMapLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMap(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _getCurrentLocation,
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.my_location, color: Colors.white),
                label: Text(
                  isLoading ? "Getting Location..." : "Use Current Location",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
            ),
            const Gaph(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Apptext(
                text: "Or select from previously applied pincodes",
                size: 14,
                color: Colors.grey,
              ),
            ),
            const Gaph(height: 10),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.2,
              ),
              child: previouslyAppliedPincodes.isEmpty
                  ? const Center(
                      child: Text("No previously applied pincodes."),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: previouslyAppliedPincodes.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: RadioListTile<String>(
                            value: previouslyAppliedPincodes[index],
                            groupValue: selectedAddress,
                            onChanged: (value) {
                              if (!_isDisposed) {
                                setState(() {
                                  selectedAddress = value;
                                  _pincodeController.text = value!;
                                });
                              }
                            },
                            title: Text(
                              previouslyAppliedPincodes[index],
                              style: const TextStyle(fontSize: 14),
                            ),
                            activeColor: Colors.red,
                          ),
                        );
                      },
                    ),
            ),
            const Gaph(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: "Enter 6 digit pincode",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  counterText: "",
                ),
              ),
            ),
            const Gaph(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  if (_pincodeController.text.length == 6) {
                    _savePincode(_pincodeController.text);
                    widget.onLocationSelected(_pincodeController.text);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid 6-digit pincode'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text(
                  "Apply",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const Gaph(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pincodeController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _showLocationPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Location Disabled"),
        content: const Text("Please enable location services to use the map."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Geolocator
                  .openLocationSettings(); // 👈 opens Google location settings
            },
            child: const Text("Enable"),
          ),
        ],
      ),
    );
  }
}
