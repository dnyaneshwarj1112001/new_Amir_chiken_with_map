import 'dart:async';
import 'dart:convert';
import 'package:meatzo/screens/Order/orderService/single_order_service.dart';
import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;

class TrackOrderMapPage extends StatefulWidget {
  final int orderId;
  final double initialLat;
  final double initialLng;

  // ignore: use_super_parameters
  const TrackOrderMapPage({
    Key? key,
    required this.orderId,
    this.initialLat = 0.0,
    this.initialLng = 0.0,
  }) : super(key: key);

  @override
  State<TrackOrderMapPage> createState() => _TrackOrderMapPageState();
}

class _TrackOrderMapPageState extends State<TrackOrderMapPage> {
  GoogleMapController? _mapController;
  Marker? _deliveryMarker;
  Marker? _userMarker;
  bool _isLoadingLocation = true;
  Timer? _pollingTimer;
  StreamSubscription<Position>? _positionStreamSubscription;
  String _distanceText = 'Calculating distance...';

  Set<Polyline> _polylines = {};

  final String googleDirectionsApiKey =
      'AIzaSyDJE0rWj8t1gv1ZYzOESjUeoLpMhGrPJ_s';

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentAndListenToUserLocation();
    _startPollingOrderLocation();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentAndListenToUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Location services are disabled. Please enable them.')),
      );
      setState(() {
        _isLoadingLocation = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')),
      );
      setState(() {
        _isLoadingLocation = false;
      });
      return;
    }

    Position initialPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _updateUserLocationMarker(initialPosition);

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _updateUserLocationMarker(position);
      _calculateDistance();
      _drawPolylineFromLocations();
    });
  }

  void _updateUserLocationMarker(Position position) {
    setState(() {
      _userMarker = Marker(
        markerId: const MarkerId('userLocation'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      if (_mapController != null && _deliveryMarker == null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
              LatLng(position.latitude, position.longitude), 14.0),
        );
      }
      _isLoadingLocation = false;
    });
  }

  Future<void> _fetchOrderLocation() async {
    try {
      final order = await SingleOrderService().fetchOrder(widget.orderId);
    
      if (order['lat'] != null && order['lng'] != null) {
        final double lat = double.tryParse(order['lat'].toString()) ?? 0.0;
        final double lng = double.tryParse(order['lng'].toString()) ?? 0.0;
       

        setState(() {
          _deliveryMarker = Marker(
            markerId: const MarkerId('deliveryLocation'),
            position: LatLng(lat, lng),
            infoWindow: const InfoWindow(title: 'Delivery Partner'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          );
        });

        if (_mapController != null && _userMarker == null) {
          _mapController
              ?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
        }

        _calculateDistance();
        _drawPolylineFromLocations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery location not available yet.')),
        );
      }
    } catch (e) {
     
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch delivery location.')),
      );
    }
  }

  void _startPollingOrderLocation() {
    _fetchOrderLocation();

    _pollingTimer = Timer.periodic(
      const Duration(minutes: 3),
      (Timer timer) {
        _fetchOrderLocation();
      },
    );
  }

  void _calculateDistance() {
    if (_userMarker != null && _deliveryMarker != null) {
      final double distanceInMeters = Geolocator.distanceBetween(
        _userMarker!.position.latitude,
        _userMarker!.position.longitude,
        _deliveryMarker!.position.latitude,
        _deliveryMarker!.position.longitude,
      );

      String distanceString;
      if (distanceInMeters < 1000) {
        distanceString = '${distanceInMeters.toStringAsFixed(0)} meters';
      } else {
        distanceString = '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
      }

      setState(() {
        _distanceText = 'Distance: $distanceString';
      });
    } else {
      setState(() {
        _distanceText = 'Calculating distance...';
      });
    }
  }

  Future<void> _drawPolylineFromLocations() async {
    if (_userMarker == null || _deliveryMarker == null) {
      setState(() {
        _polylines = {};
      });
      return;
    }

    final String origin =
        '${_userMarker!.position.latitude},${_userMarker!.position.longitude}';
    final String destination =
        '${_deliveryMarker!.position.latitude},${_deliveryMarker!.position.longitude}';

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$googleDirectionsApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final String encodedPolyline =
              data['routes'][0]['overview_polyline']['points'];

          PolylinePoints polylinePointsDecoder = PolylinePoints();
          List<PointLatLng> decodedPoints =
              polylinePointsDecoder.decodePolyline(encodedPolyline);
          List<LatLng> polylineCoordinates = decodedPoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

          final Polyline polyline = Polyline(
            polylineId: const PolylineId('path_to_delivery'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          );
          setState(() {
            _polylines = {polyline};
          });
        } else {
          _drawStraightLine();
        }
      } else {
        _drawStraightLine();
      }
    } catch (e) {
      _drawStraightLine();
    }
  }

  void _drawStraightLine() {
    if (_userMarker != null && _deliveryMarker != null) {
      final Polyline polyline = Polyline(
        polylineId: const PolylineId('path_to_delivery'),
        points: [
          _userMarker!.position,
          _deliveryMarker!.position,
        ],
        color: Colors.blue,
        width: 5,
      );
      setState(() {
        _polylines = {polyline};
      });
    } else {
      setState(() {
        _polylines = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> allMarkers = {};
    if (_deliveryMarker != null) {
      allMarkers.add(_deliveryMarker!);
    }
    if (_userMarker != null) {
      allMarkers.add(_userMarker!);
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Track Order",
        titleColor: Colors.white,
        titleFontWeight: FontWeight.bold,
      ),
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;

                    if (_deliveryMarker != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                            _deliveryMarker!.position, 14.0),
                      );
                    } else if (_userMarker != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(_userMarker!.position, 14.0),
                      );
                    } else {
                      _mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(_initialCameraPosition),
                      );
                    }
                  },
                  initialCameraPosition: _initialCameraPosition,
                  markers: allMarkers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        _distanceText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
