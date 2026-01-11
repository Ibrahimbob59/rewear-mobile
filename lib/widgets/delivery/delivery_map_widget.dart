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
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(DeliveryMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPosition != oldWidget.currentPosition ||
        widget.delivery != oldWidget.delivery) {
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    // Pickup marker - ✅ FIXED null handling
    if (widget.delivery.pickupLatitude != null && 
        widget.delivery.pickupLongitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(
            widget.delivery.pickupLatitude!,  // ✅ FIXED
            widget.delivery.pickupLongitude!, // ✅ FIXED
          ),
          infoWindow: InfoWindow(
            title: 'Pickup Location',
            snippet: widget.delivery.pickupAddress ?? 'Pickup point',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Delivery marker - ✅ FIXED null handling
    if (widget.delivery.deliveryLatitude != null && 
        widget.delivery.deliveryLongitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('delivery'),
          position: LatLng(
            widget.delivery.deliveryLatitude!,  // ✅ FIXED
            widget.delivery.deliveryLongitude!, // ✅ FIXED
          ),
          infoWindow: InfoWindow(
            title: 'Delivery Location',
            snippet: widget.delivery.deliveryAddress ?? 'Delivery point',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    // Current position marker - ✅ FIXED null handling
    if (widget.currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(
            widget.currentPosition!.latitude,  // ✅ FIXED
            widget.currentPosition!.longitude, // ✅ FIXED
          ),
          infoWindow: const InfoWindow(
            title: 'Your Location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  LatLng _getCenter() {
    // ✅ FIXED - Proper null handling
    if (widget.currentPosition != null) {
      return LatLng(
        widget.currentPosition!.latitude,
        widget.currentPosition!.longitude,
      );
    }

    // If picked up, center on delivery location
    if (widget.delivery.isPickedUp && 
        widget.delivery.deliveryLatitude != null &&
        widget.delivery.deliveryLongitude != null) {
      return LatLng(
        widget.delivery.deliveryLatitude!,
        widget.delivery.deliveryLongitude!,
      );
    }

    // Otherwise center on pickup location
    if (widget.delivery.pickupLatitude != null &&
        widget.delivery.pickupLongitude != null) {
      return LatLng(
        widget.delivery.pickupLatitude!,
        widget.delivery.pickupLongitude!,
      );
    }

    // Default to Beirut if no coordinates
    return const LatLng(33.8938, 35.5018);
  }

  double _getZoom() {
    // ✅ FIXED - Proper null handling
    if (_markers.length > 1 &&
        widget.delivery.pickupLatitude != null &&
        widget.delivery.pickupLongitude != null &&
        widget.delivery.deliveryLatitude != null &&
        widget.delivery.deliveryLongitude != null) {
      
      final pickupLat = widget.delivery.pickupLatitude!;
      final pickupLng = widget.delivery.pickupLongitude!;
      final deliveryLat = widget.delivery.deliveryLatitude!;
      final deliveryLng = widget.delivery.deliveryLongitude!;

      // Calculate bounds
      final minLat = pickupLat < deliveryLat ? pickupLat : deliveryLat;
      final maxLat = pickupLat > deliveryLat ? pickupLat : deliveryLat;
      final minLng = pickupLng < deliveryLng ? pickupLng : deliveryLng;
      final maxLng = pickupLng > deliveryLng ? pickupLng : deliveryLng;

      final latDiff = maxLat - minLat;
      final lngDiff = maxLng - minLng;
      final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

      if (maxDiff < 0.01) return 14.0;
      if (maxDiff < 0.05) return 12.0;
      if (maxDiff < 0.1) return 11.0;
      return 10.0;
    }

    return 13.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),  // ✅ FIXED deprecation
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _getCenter(),
            zoom: _getZoom(),
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          onMapCreated: (controller) {
            _mapController = controller;
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}