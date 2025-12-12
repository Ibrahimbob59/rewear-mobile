import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/delivery_model.dart';

class DeliveryMapWidget extends StatefulWidget {
  final Delivery delivery;
  final Position? currentPosition;

  const DeliveryMapWidget({
    super.key,
    required this.delivery,
    this.currentPosition,
  });

  @override
  State<DeliveryMapWidget> createState() => _DeliveryMapWidgetState();
}

class _DeliveryMapWidgetState extends State<DeliveryMapWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setupMarkers();
  }

  @override
  void didUpdateWidget(DeliveryMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPosition != widget.currentPosition) {
      _setupMarkers();
    }
  }

  void _setupMarkers() {
    _markers.clear();

    // Pickup marker
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(
          widget.delivery.pickupLatitude,
          widget.delivery.pickupLongitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ),
    );

    // Delivery marker
    _markers.add(
      Marker(
        markerId: const MarkerId('delivery'),
        position: LatLng(
          widget.delivery.deliveryLatitude,
          widget.delivery.deliveryLongitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Delivery Location'),
      ),
    );

    // Current position marker (driver)
    if (widget.currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(
            widget.currentPosition!.latitude,
            widget.currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'Driver Location'),
        ),
      );
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.delivery.pickupLatitude,
            widget.delivery.pickupLongitude,
          ),
          zoom: 13,
        ),
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;
          _fitMapToMarkers();
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }

  void _fitMapToMarkers() {
    if (_mapController == null) return;

    final bounds = _calculateBounds();
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  LatLngBounds _calculateBounds() {
    double minLat = widget.delivery.pickupLatitude;
    double maxLat = widget.delivery.pickupLatitude;
    double minLng = widget.delivery.pickupLongitude;
    double maxLng = widget.delivery.pickupLongitude;

    // Include delivery location
    if (widget.delivery.deliveryLatitude < minLat) {
      minLat = widget.delivery.deliveryLatitude;
    }
    if (widget.delivery.deliveryLatitude > maxLat) {
      maxLat = widget.delivery.deliveryLatitude;
    }
    if (widget.delivery.deliveryLongitude < minLng) {
      minLng = widget.delivery.deliveryLongitude;
    }
    if (widget.delivery.deliveryLongitude > maxLng) {
      maxLng = widget.delivery.deliveryLongitude;
    }

    // Include current position if available
    if (widget.currentPosition != null) {
      if (widget.currentPosition!.latitude < minLat) {
        minLat = widget.currentPosition!.latitude;
      }
      if (widget.currentPosition!.latitude > maxLat) {
        maxLat = widget.currentPosition!.latitude;
      }
      if (widget.currentPosition!.longitude < minLng) {
        minLng = widget.currentPosition!.longitude;
      }
      if (widget.currentPosition!.longitude > maxLng) {
        maxLng = widget.currentPosition!.longitude;
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}