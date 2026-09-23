import 'package:flutter/material.dart';

class MapFloatingActions extends StatelessWidget {
  final VoidCallback onMyLocationPressed;
  final VoidCallback onRefreshPressed;
  final bool isLocating;

  const MapFloatingActions({
    super.key,
    required this.onMyLocationPressed,
    required this.onRefreshPressed,
    this.isLocating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'refresh_layer',
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E88E5),
          elevation: 3,
          onPressed: onRefreshPressed,
          tooltip: 'Refresh Layer GEO MAPID',
          child: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'my_location',
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          elevation: 4,
          onPressed: isLocating ? null : onMyLocationPressed,
          tooltip: 'Lokasi Saya (GPS)',
          child: isLocating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Icon(Icons.my_location_rounded),
        ),
      ],
    );
  }
}
