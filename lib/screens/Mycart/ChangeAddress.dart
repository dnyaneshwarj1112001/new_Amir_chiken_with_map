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
import 'package:meatzo/presentation/Global_widget/gap.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

// Replace with your actual Google Maps API Key
const Maps_API_KEY = "AIzaSyDJE0rWj8t1gv1ZYzOESjUeoLpMhGrPJ_s";

class AddressEntryScreen extends StatefulWidget {
  const AddressEntryScreen({super.key});

  @override
  State<AddressEntryScreen> createState() => _AddressEntryScreenState();
}

class _AddressEntryScreenState extends State<AddressEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

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
  bool isLocationLoading = true;
  bool isMapLoading = true;

  String? latitude;
  String? longitude;
  String? currentAddress;

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
    // Check initial form validity
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFormValidity();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    if (!mounted) return;

    try {
      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Location services are disabled. Please enable location services.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        _setDefaultLocation();
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied'),
                backgroundColor: Colors.red,
              ),
            );
          }
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Location permissions are permanently denied. Please enable in settings.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _setDefaultLocation();
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      latitude = position.latitude.toString();
      longitude = position.longitude.toString();

      LatLng initialLocation = LatLng(position.latitude, position.longitude);
      _currentCameraPosition = initialLocation;
      _addMarker(initialLocation, "Current Location");

      await _updateAddressFromCoordinates(
          position.latitude, position.longitude);

      setState(() {
        isLocationLoading = false;
        isMapLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    if (!mounted) return;

    _currentCameraPosition = const LatLng(20.5937, 78.9629); // Default India
    _addMarker(_currentCameraPosition!, "Default Location");

    setState(() {
      isLocationLoading = false;
      isMapLoading = false;
      countryController.text = "India";
      stateController.text = "Maharashtra";
      cityController.text = "Mumbai";
    });
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
    if (!mounted) return;

    _addMarker(tappedLatLng, "Selected Location");
    latitude = tappedLatLng.latitude.toString();
    longitude = tappedLatLng.longitude.toString();

    await _updateAddressFromCoordinates(
        tappedLatLng.latitude, tappedLatLng.longitude);
  }

  Future<void> _onCameraIdle() async {
    if (!mounted || _currentCameraPosition == null) return;

    await _updateAddressFromCoordinates(
      _currentCameraPosition!.latitude,
      _currentCameraPosition!.longitude,
    );
  }

  Future<void> _updateAddressFromCoordinates(double lat, double lng) async {
    if (!mounted) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        setState(() {
          // streetController.text = place.street?.isNotEmpty == false
          //     ? place.street!
          //     : "${place.name ?? ''}, ${place.subLocality ?? ''}";
          streetController.text = [
            // place.name,
            place.subLocality,
            place.locality,
            place.subAdministrativeArea,
            place.administrativeArea,
            place.postalCode,
            place.country
          ].where((e) => e != null && e.isNotEmpty).join(", ");

          cityController.text = place.locality ?? '';
          stateController.text = place.administrativeArea ?? '';
          countryController.text = place.country ?? '';
          pinController.text = place.postalCode ?? '';
          latitude = lat.toString();
          longitude = lng.toString();
          currentAddress =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
        });
        _checkFormValidity();
      }
    } catch (e) {
      // ignore
    }
  }

  void _addMarker(LatLng position, String title) {
    if (!mounted) return;

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(title),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (searchController.text.isNotEmpty && mounted) {
        _getPlaceSuggestions(searchController.text);
      } else if (mounted) {
        setState(() {
          _placePredictions = [];
        });
      }
    });
  }

  Future<void> _getPlaceSuggestions(String query) async {
    if (!mounted) return;

    try {
      PlacesAutocompleteResponse response = await _places.autocomplete(
        query,
        language: "en",
        types: ["address"],
        components: [Component(Component.country, "in")],
      );

      if (mounted) {
        if (response.status == "OK") {
          setState(() {
            _placePredictions = response.predictions;
          });
        } else {
          setState(() {
            _placePredictions = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _placePredictions = [];
        });
      }
    }
  }

  Future<void> _selectPlace(Prediction prediction) async {
    if (!mounted) return;

    searchController.removeListener(_onSearchChanged);

    setState(() {
      _placePredictions = [];
      searchController.text = prediction.description!;
      streetController.text = prediction.description!;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        searchController.addListener(_onSearchChanged);
      }
    });

    try {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(prediction.placeId!);
      if (detail.status == "OK" && mounted) {
        final geometry = detail.result.geometry;
        final lat = geometry?.location.lat;
        final lng = geometry?.location.lng;

        if (lat != null && lng != null) {
          LatLng selectedLatLng = LatLng(lat, lng);
          _addMarker(selectedLatLng, prediction.description!);
          latitude = lat.toString();
          longitude = lng.toString();

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
          if (placemarks.isNotEmpty && mounted) {
            final place = placemarks.first;
            setState(() {
              // Auto-fill street address with selected location
              streetController.text = place.street?.isNotEmpty == true
                  ? place.street!
                  : prediction.description!;
              cityController.text = place.locality ?? '';
              stateController.text = place.administrativeArea ?? '';
              countryController.text = place.country ?? '';
              pinController.text = place.postalCode ?? '';
            });
            _checkFormValidity();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          streetController.text = prediction.description!;
        });
      }
    }
  }

  void _checkFormValidity() {
    if (!mounted) return;

    // Check if all required fields are filled
    bool isValid = true;

    // Check street address
    if (streetController.text.trim().isEmpty) {
      isValid = false;
    }

    // Check city
    if (cityController.text.trim().isEmpty) {
      isValid = false;
    }

    // Check state
    if (stateController.text.trim().isEmpty) {
      isValid = false;
    }

    // Check country
    if (countryController.text.trim().isEmpty) {
      isValid = false;
    }

    // Check pin code (must be 6 digits)
    if (pinController.text.trim().isEmpty || pinController.text.length != 6) {
      isValid = false;
    }

    // Check phone number
    if (phoneController.text.trim().isEmpty) {
      isValid = false;
    }

    // Check if location is selected
    if (latitude == null || longitude == null) {
      isValid = false;
    }

    if (isValid != isFormValid) {
      setState(() => isFormValid = isValid);
    }
  }

  Future<void> _submit() async {
    if (!mounted) return;

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

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    responseBody['message'] ?? "Address saved successfully!"),
                backgroundColor: Colors.green,
              ),
            );

            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyCardScreen()),
                );
              }
            });
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ Failed: ${response.statusCode}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ Error: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool isRequired = false,
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: isRequired ? "$label *" : label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: Appcolor.primaryRed, size: 20),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Appcolor.primaryRed, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[400]!, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[400]!, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
        onChanged: (_) => _checkFormValidity(),
        onFieldSubmitted: (_) => _checkFormValidity(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLocationLoading) {
      return Scaffold(
        appBar: const CustomAppBar(title: "Enter Delivery Address"),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Appcolor.primaryRed),
              const SizedBox(height: 20),
              Text(
                "Getting your location...",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: "Enter Delivery Address",
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.myCart),
        ),
      ),
      body: Form(
        key: _formKey,
        onChanged: _checkFormValidity,
        child: Column(
          children: [
            // Search and Map Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search for location...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon:
                            Icon(Icons.search, color: Appcolor.primaryRed),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon:
                                    Icon(Icons.clear, color: Colors.grey[400]),
                                onPressed: () {
                                  setState(() {
                                    searchController.clear();
                                    _placePredictions = [];
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Appcolor.primaryRed, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),

                  // Search suggestions
                  if (_placePredictions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: SizedBox(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _placePredictions.length,
                            itemBuilder: (context, index) {
                              final prediction = _placePredictions[index];
                              return ListTile(
                                leading: Icon(Icons.location_on,
                                    color: Appcolor.primaryRed),
                                title: Text(
                                  prediction.description ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                onTap: () => _selectPlace(prediction),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Map
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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
                        zoomControlsEnabled: false,
                        onTap: _updateLocationFromTap,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "Tap on map to select location or search above",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Form Fields Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Address Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildInputField(
                        controller: streetController,
                        label: "Street Address",
                        icon: Icons.home,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Street address is required";
                          }
                          return null;
                        },
                        isRequired: true,
                        maxLines: 2,
                      ),

                      _buildInputField(
                        controller: cityController,
                        label: "City",
                        icon: Icons.location_city,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "City is required";
                          }
                          return null;
                        },
                        isRequired: true,
                      ),

                      _buildInputField(
                        controller: stateController,
                        label: "State",
                        icon: Icons.map,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "State is required";
                          }
                          return null;
                        },
                        isRequired: true,
                      ),

                      _buildInputField(
                        controller: countryController,
                        label: "Country",
                        icon: Icons.flag,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Country is required";
                          }
                          return null;
                        },
                        isRequired: true,
                      ),

                      _buildInputField(
                        controller: pinController,
                        label: "Pin Code",
                        icon: Icons.pin_drop,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Pin Code is required";
                          }
                          if (value.trim().length != 6) {
                            return "Pin Code must be exactly 6 digits";
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                            return "Pin Code must contain only numbers";
                          }
                          return null;
                        },
                        isRequired: true,
                        keyboardType: TextInputType.number,
                      ),

                      // Phone Field
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: IntlPhoneField(
                          decoration: InputDecoration(
                            labelText: "Phone Number *",
                            labelStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Appcolor.primaryRed, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
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
                            if (phone.number.length < 10) {
                              return "Phone number must be at least 10 digits";
                            }
                            return null;
                          },
                        ),
                      ),

                      // Default Address Switch
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Appcolor.primaryRed),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Set as Default Address",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            Switch(
                              value: isDefault,
                              onChanged: (val) =>
                                  setState(() => isDefault = val),
                              activeColor: Appcolor.primaryRed,
                            ),
                          ],
                        ),
                      ),

                      // Validation Status
                      if (!isFormValid)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.orange[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Please fill all required fields marked with * to enable Save Address button",
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isFormValid && !isLoading ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFormValid
                                ? Appcolor.primaryRed
                                : Colors.grey[400],
                            foregroundColor: Colors.white,
                            elevation: isFormValid ? 2 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isFormValid
                                      ? "Save Address"
                                      : "Fill Required Fields",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF9A292F),
        currentIndex: 1, // Cart tab index
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.home);
              break;
            case 1:
              // Already on cart page
              break;
            case 2:
              Navigator.pushReplacementNamed(context, AppRoutes.order);
              break;
            case 3:
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'MyCart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
