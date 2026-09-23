import 'package:flutter/material.dart';

class MapFloatingActions extends StatelessWidget {
  final VoidCallback onMyLocationPressed;
  final VoidCallback onRefreshPressed;
  final VoidCallback? onZoomInPressed;
  final VoidCallback? onZoomOutPressed;
  final VoidCallback? onCompassPressed;
  final VoidCallback? onLayersPressed;
  final bool isLocating;

  const MapFloatingActions({
    super.key,
    required this.onMyLocationPressed,
    required this.onRefreshPressed,
    this.onZoomInPressed,
    this.onZoomOutPressed,
    this.onCompassPressed,
    this.onLayersPressed,
    this.isLocating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compass (North) Button
        _buildCircularMapButton(
          icon: Icons.navigation_rounded,
          iconColor: const Color(0xFFDC2626),
          tooltip: 'Arah Utara',
          onTap: onCompassPressed,
        ),
        const SizedBox(height: 10),

        // Zoom In & Out Card (Matching reference)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          child: Column(
            children: [
              _buildSmallIconButton(
                icon: Icons.add_rounded,
                tooltip: 'Perbesar Peta',
                onTap: onZoomInPressed,
              ),
              Container(height: 1, width: 28, color: const Color(0xFFE2E8F0)),
              _buildSmallIconButton(
                icon: Icons.remove_rounded,
                tooltip: 'Perkecil Peta',
                onTap: onZoomOutPressed,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Layer Style Button (OSM/MapLibre)
        _buildCircularMapButton(
          icon: Icons.layers_rounded,
          iconColor: const Color(0xFF2563EB),
          tooltip: 'Layer Basemap',
          onTap: onLayersPressed ?? onRefreshPressed,
        ),
        const SizedBox(height: 10),

        // GPS My Location Button (Vibrant Blue matching reference)
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withAlpha(80),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: isLocating ? null : onMyLocationPressed,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: isLocating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularMapButton({
    required IconData icon,
    required Color iconColor,
    required String tooltip,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Center(
              child: Icon(icon, color: iconColor, size: 21),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: const Color(0xFF334155), size: 22),
        ),
      ),
    );
  }
}
