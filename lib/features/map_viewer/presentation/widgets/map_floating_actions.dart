import 'package:flutter/material.dart';

class MapFloatingActions extends StatelessWidget {
  final VoidCallback onMyLocationPressed;
  final VoidCallback onRefreshPressed;
  final VoidCallback? onZoomInPressed;
  final VoidCallback? onZoomOutPressed;
  final bool isLocating;

  const MapFloatingActions({
    super.key,
    required this.onMyLocationPressed,
    required this.onRefreshPressed,
    this.onZoomInPressed,
    this.onZoomOutPressed,
    this.isLocating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zoom controls card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 14,
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
        const SizedBox(height: 14),

        // Refresh layer button
        _buildActionFab(
          tooltip: 'Refresh Layer',
          icon: Icons.sync_rounded,
          color: Colors.white,
          iconColor: const Color(0xFF2563EB),
          onTap: onRefreshPressed,
        ),
        const SizedBox(height: 12),

        // My location GPS button with pulsing shadow
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withAlpha(80),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isLocating ? null : onMyLocationPressed,
              child: SizedBox(
                width: 52,
                height: 52,
                child: Center(
                  child: isLocating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
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

  Widget _buildActionFab({
    required String tooltip,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
