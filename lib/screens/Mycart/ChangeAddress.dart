import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:meatzo/screens/Mycart/Screens/MyCartScreen.dart';
import 'package:meatzo/core/network/httpservice.dart';
import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';
import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

// Replace with your actual Google Maps API Key
// ignore: constant_identifier_names
const Maps_API_KEY = "AIzaSyDJE0rWj8t1gv1ZYzOESjUeoLpMhGrPJ_s";

class AddressEntryScreen extends StatefulWidget {
  const AddressEntryScreen({super.key});

  @override
  State<AddressEntryScreen> createState() => _AddressEntryScreenState();
}

class _AddressEntryScreenState extends State<AddressEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController streetController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String countryCode = "+91";
  bool isDefault = true;
  bool isFormValid = false;
  bool isLoading = false;

  String? latitude;
  String? longitude;
  bool isLocationLoading = true;

  // Google Maps related
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _currentCameraPosition;
  final Set<Marker> _markers = {};
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Maps_API_KEY);

  Timer? _debounce;
  List<Prediction> _placePredictions = [];

  @override
  void initState() {
    super.initState();
    _places = GoogleMapsPlaces(apiKey: Maps_API_KEY);
    _getCurrentLocationAndAddress();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    streetController.dispose();
    pinController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocationAndAddress() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();

      LatLng initialLocation = LatLng(position.latitude, position.longitude);
      _currentCameraPosition = initialLocation;
      _addMarker(initialLocation, "Current Location");

      await _updateAddressFromCoordinates(
          position.latitude, position.longitude);

      setState(() => isLocationLoading = false);
    } catch (e) {
      setState(() => isLocationLoading = false);
      _currentCameraPosition = const LatLng(20.5937, 78.9629); // Default India
      _addMarker(_currentCameraPosition!, "Default Location");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_mapController.isCompleted) {
      _mapController.complete(controller);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentCameraPosition = position.target;
  }

  Future<void> _updateLocationFromTap(LatLng tappedLatLng) async {
    _addMarker(tappedLatLng, "Selected Location");
    latitude = tappedLatLng.latitude.toString();
    longitude = tappedLatLng.longitude.toString();

    await _updateAddressFromCoordinates(
        tappedLatLng.latitude, tappedLatLng.longitude);
  }

  Future<void> _onCameraIdle() async {
    if (_currentCameraPosition != null) {
      await _updateAddressFromCoordinates(
          _currentCameraPosition!.latitude, _currentCameraPosition!.longitude);
    }
  }

  Future<void> _updateAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          streetController.text =
              "${place.name ?? ''}, ${place.street ?? ''}".trim();
          cityController.text = place.locality ?? '';
          stateController.text = place.administrativeArea ?? '';
          countryController.text = place.country ?? '';
          pinController.text = place.postalCode ?? '';
          latitude = lat.toString();
          longitude = lng.toString();
        });
        _checkFormValidity();
      }
    } catch (e) {
      // ignore
    }
  }

  void _addMarker(LatLng position, String title) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(title),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (searchController.text.isNotEmpty) {
        _getPlaceSuggestions(searchController.text);
      } else {
        setState(() {
          _placePredictions = [];
        });
      }
    });
  }

  Future<void> _getPlaceSuggestions(String query) async {
    try {
      PlacesAutocompleteResponse response = await _places.autocomplete(query,
          language: "en",
          types: ["address"],
          components: [Component(Component.country, "in")]);
      if (response.status == "OK") {
        setState(() {
          _placePredictions = response.predictions;
        });
      } else {
        setState(() {
          _placePredictions = [];
        });
      }
    } catch (e) {
      setState(() {
        _placePredictions = [];
      });
    }
  }

  Future<void> _selectPlace(Prediction prediction) async {
    searchController.removeListener(_onSearchChanged);

    setState(() {
      _placePredictions = [];
      searchController.text = prediction.description!;
      streetController.text = prediction.description!;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      searchController.addListener(_onSearchChanged);
    });

    try {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(prediction.placeId!);
      if (detail.status == "OK") {
        final geometry = detail.result.geometry;
        final lat = geometry?.location.lat;
        final lng = geometry?.location.lng;

        if (lat != null && lng != null) {
          LatLng selectedLatLng = LatLng(lat, lng);
          _addMarker(selectedLatLng, prediction.description!);
          latitude = lat.toString();
          longitude = lng.toString();

          // Only animate camera if widget is still mounted and controller is ready
          if (mounted && _mapController.isCompleted) {
            try {
              final GoogleMapController controller =
                  await _mapController.future;
              await controller.animateCamera(
                CameraUpdate.newLatLngZoom(selectedLatLng, 16),
              );
            } catch (e) {
              // Ignore camera errors
            }
          }

          List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            setState(() {
              streetController.text = place.street?.isNotEmpty == true
                  ? place.street!
                  : prediction.description!;
              cityController.text = place.locality ?? '';
              stateController.text = place.administrativeArea ?? '';
              countryController.text = place.country ?? '';
              pinController.text = place.postalCode ?? '';
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        streetController.text = prediction.description!;
      });
    }
  }

  void _checkFormValidity() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid != isFormValid) {
      setState(() => isFormValid = isValid);
    }
  }

  Future<void> _submit() async {
    checkvalidation() {
      if (streetController.text.isEmpty) {
        return "Street address is required";
      }
      if (cityController.text.isEmpty) {
        return "City is required";
      }
      if (stateController.text.isEmpty) {
        return "State is required";
      }
      if (countryController.text.isEmpty) {
        return "Country is required";
      }
      if (pinController.text.isEmpty) {
        return "Pin code is required";
      }
      if (phoneController.text.isEmpty) {
        return "Mobile number is required";
      }
      return null;
    }

    if (_formKey.currentState!.validate()) {
      final data = {
        "country": countryController.text,
        "state": stateController.text,
        "city": cityController.text,
        "street_address": streetController.text,
        "pin_code": pinController.text,
        "mobile_number": phoneController.text,
        "country_code": countryCode,
        "is_default": isDefault,
        if (latitude != null) "lat": latitude,
        if (longitude != null) "lng": longitude,
      };

      setState(() => isLoading = true);

      try {
        final response = await HttpClient.post("/addresses", data);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseBody = jsonDecode(response.body);

          final box = await Hive.openBox('addressBox');
          box.put('city', cityController.text);
          box.put('state', stateController.text);
          box.put('pin', pinController.text);
          box.put('mobile', phoneController.text);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  responseBody['message'] ?? "Address saved successfully!"),
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyCardScreen()),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Failed: ${response.statusCode}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e")),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {bool isRequired = false}) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      label: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Apptext(
                text: label,
                color: Colors.blueGrey,
                size: 14,
              ),
            ),
            if (isRequired)
              const WidgetSpan(
                child: Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
      prefixIcon: Icon(icon, color: Colors.blueGrey, size: 20),
      filled: true,
      fillColor: Colors.grey[200],
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLocationLoading || _currentCameraPosition == null) {
      return const Scaffold(
        appBar: CustomAppBar(title: "Enter Delivery Address"),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: "Enter Delivery Address"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          onChanged: _checkFormValidity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextFormField(
                controller: searchController,
                decoration:
                    _inputDecoration("Search Location", Icons.search).copyWith(
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.blueGrey),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              _placePredictions = [];
                            });
                          },
                        )
                      : null,
                ),
              ),

              // Show search suggestions as a list
              if (_placePredictions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _placePredictions.length,
                    itemBuilder: (context, index) {
                      final prediction = _placePredictions[index];
                      return ListTile(
                        title: Text(prediction.description ?? ''),
                        onTap: () => _selectPlace(prediction),
                      );
                    },
                  ),
                ),

              // Google Map
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueGrey),
                ),
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _currentCameraPosition!,
                    zoom: 15,
                  ),
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  markers: _markers,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  onTap: (LatLng latLng) {
                    _updateLocationFromTap(latLng);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Address fields
              TextFormField(
                controller: streetController,
                decoration: _inputDecoration("Selected Address", Icons.home,
                    isRequired: true),
                validator: (value) =>
                    value!.isEmpty ? "Address is required" : null,
                onChanged: (_) => _checkFormValidity(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: cityController,
                decoration: _inputDecoration("City", Icons.location_city,
                    isRequired: true),
                validator: (value) =>
                    value!.isEmpty ? "City is required" : null,
                onChanged: (_) => _checkFormValidity(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: stateController,
                decoration:
                    _inputDecoration("State", Icons.map, isRequired: true),
                validator: (value) =>
                    value!.isEmpty ? "State is required" : null,
                onChanged: (_) => _checkFormValidity(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: countryController,
                decoration:
                    _inputDecoration("Country", Icons.flag, isRequired: true),
                validator: (value) =>
                    value!.isEmpty ? "Country is required" : null,
                onChanged: (_) => _checkFormValidity(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: pinController,
                keyboardType: TextInputType.number,
                decoration:
                    _inputDecoration("Pin Code", Icons.pin, isRequired: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Pin Code is required";
                    return "Pin Code must be 6 digits";
                  }
                  return null;
                },
                onChanged: (_) => _checkFormValidity(),
              ),
              const SizedBox(height: 10),
              IntlPhoneField(
                decoration: _inputDecoration("Phone Number", Icons.phone,
                    isRequired: true),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  if (phone.number.isEmpty) {
                    phoneController.clear();
                  } else {
                    phoneController.text = phone.number;
                  }
                  countryCode = phone.countryCode;
                  _checkFormValidity();
                },
                validator: (phone) {
                  if (phone == null ||
                      phone.number.isEmpty ||
                      phoneController.text.isEmpty) {
                    return "Phone number is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: isDefault,
                onChanged: (val) => setState(() => isDefault = val),
                title: const Apptext(
                  text: "Set as Default Address",
                  color: Colors.black87,
                  size: 14,
                ),
                activeColor: Colors.blueGrey,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isFormValid && !isLoading ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Appcolor.primaryRed,
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Apptext(
                        text: "Save Address",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
