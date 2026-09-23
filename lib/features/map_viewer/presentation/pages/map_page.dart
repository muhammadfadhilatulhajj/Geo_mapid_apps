import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/geo_feature_entity.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../widgets/feature_detail_sheet.dart';
import '../widgets/map_floating_actions.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapLibreMapController? _mapController;
  final Map<String, GeoFeatureEntity> _featuresById = {};
  Circle? _userLocationCircle;
  Circle? _userLocationPulseCircle;
  int _selectedBottomNav = 0;
  String _activeCategoryFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(const LoadGeoLayerEvent());
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    controller.onCircleTapped.add(_onCircleTapped);
  }

  void _onStyleLoaded() {
    final state = context.read<MapBloc>().state;
    if (state.layer != null) {
      _renderGeoLayer(state.layer!.features);
    }
  }

  void _onCircleTapped(Circle circle) {
    HapticFeedback.lightImpact();
    final feature = _featuresById[circle.id];
    if (feature != null) {
      context.read<MapBloc>().add(SelectFeatureEvent(feature));
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(feature.latitude, feature.longitude),
          15.2,
        ),
      );
    }
  }

  Future<void> _renderGeoLayer(List<GeoFeatureEntity> features) async {
    if (_mapController == null) return;

    _featuresById.clear();
    await _mapController?.clearCircles();

    final filtered = _activeCategoryFilter == 'Semua'
        ? features
        : features.where((f) => f.district.contains(_activeCategoryFilter)).toList();

    for (final feature in filtered) {
      // Emerald Green marker matching the reference screenshot design
      final circle = await _mapController?.addCircle(
        CircleOptions(
          geometry: LatLng(feature.latitude, feature.longitude),
          circleColor: '#059669',
          circleRadius: 9.0,
          circleStrokeWidth: 3.0,
          circleStrokeColor: '#FFFFFF',
          circleOpacity: 0.95,
          draggable: false,
        ),
      );

      if (circle != null) {
        _featuresById[circle.id] = feature;
      }
    }
  }

  Future<void> _updateUserLocationMarker(double lat, double lng) async {
    if (_mapController == null) return;

    final target = LatLng(lat, lng);

    if (_userLocationCircle != null) {
      if (_userLocationPulseCircle != null) {
        await _mapController?.updateCircle(
          _userLocationPulseCircle!,
          CircleOptions(geometry: target),
        );
      }
      await _mapController?.updateCircle(
        _userLocationCircle!,
        CircleOptions(geometry: target),
      );
    } else {
      // Pulse outer halo
      _userLocationPulseCircle = await _mapController?.addCircle(
        CircleOptions(
          geometry: target,
          circleColor: '#3B82F6',
          circleRadius: 22.0,
          circleOpacity: 0.22,
          circleStrokeWidth: 0.0,
        ),
      );

      // Inner GPS marker
      _userLocationCircle = await _mapController?.addCircle(
        CircleOptions(
          geometry: target,
          circleColor: '#2563EB',
          circleRadius: 9.5,
          circleStrokeWidth: 3.5,
          circleStrokeColor: '#FFFFFF',
          circleOpacity: 1.0,
          draggable: false,
        ),
      );
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, 15.5),
    );
  }

  void _resetNorth() {
    _mapController?.animateCamera(
      CameraUpdate.bearingTo(0.0),
    );
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state.status == MapStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (state.status == MapStatus.loaded && state.layer != null) {
            _renderGeoLayer(state.layer!.features);
          }

          if (state.userLocation != null) {
            _updateUserLocationMarker(
              state.userLocation!.$1,
              state.userLocation!.$2,
            );
          }
        },
        builder: (context, state) {
          final totalCount = state.layer?.features.length ?? 0;

          return Stack(
            children: [
              // MapLibre GL with OpenFreeMap Liberty Style
              MapLibreMap(
                styleString: AppConstants.openFreeMapStyleUrl,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(
                    AppConstants.defaultLatitude,
                    AppConstants.defaultLongitude,
                  ),
                  zoom: AppConstants.defaultZoom,
                ),
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoaded,
                myLocationEnabled: false,
                trackCameraPosition: true,
                compassEnabled: false, // Custom compass implemented in actions
              ),

              // Top Bar & Filter Chips Header (Matching Reference Screenshot)
              SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top App Header
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(16),
                            blurRadius: 14,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Brand icon
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.explore_rounded,
                                color: Color(0xFF38BDF8),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Geo MAPID',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Peta Explorer • Pariwisata Jogja',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Accuracy badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.satellite_alt_rounded,
                                  size: 13,
                                  color: Color(0xFF16A34A),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '±2.4m',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF15803D),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Profile avatar circle
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF065F46),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Layer Pill & Projection Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0).withAlpha(160),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF059669),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Layer: Pariwisata Jogja ($totalCount)',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Row(
                            children: [
                              Icon(
                                Icons.public_rounded,
                                size: 12,
                                color: Color(0xFF64748B),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'WGS84',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Search Bar Box
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 14,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Cari objek wisata di Yogyakarta...',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Horizontal Filter Chips
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildFilterChip('Semua ($totalCount)', 'Semua'),
                          _buildFilterChip('Gondomanan', 'GONDOMANAN'),
                          _buildFilterChip('Umbulharjo', 'UMBULHARJO'),
                          _buildFilterChip('Gondokusuman', 'GONDOKUSUMAN'),
                          _buildFilterChip('Danurejan', 'DANUREJAN'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tooltip Pill: "Ketuk marker detail ↗"
              Positioned(
                top: 198,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withAlpha(220),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          color: Color(0xFF34D399),
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Ketuk marker titik untuk info detail',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Floating Controls Stack (North, Zoom In/Out, Layer, GPS)
              Positioned(
                right: 16,
                bottom: state.selectedFeature != null ? 360 : 36,
                child: MapFloatingActions(
                  isLocating: state.isLocatingUser,
                  onCompassPressed: _resetNorth,
                  onZoomInPressed: _zoomIn,
                  onZoomOutPressed: _zoomOut,
                  onLayersPressed: () {
                    HapticFeedback.selectionClick();
                    context.read<MapBloc>().add(const LoadGeoLayerEvent());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Layer GEO MAPID di-refresh!'),
                        duration: Duration(milliseconds: 1200),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  onRefreshPressed: () {
                    context.read<MapBloc>().add(const LoadGeoLayerEvent());
                  },
                  onMyLocationPressed: () {
                    HapticFeedback.selectionClick();
                    context.read<MapBloc>().add(const GetUserLocationEvent());
                  },
                ),
              ),

              // Interactive Detail Bottom Sheet Modal
              if (state.selectedFeature != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: FeatureDetailSheet(
                      key: ValueKey(state.selectedFeature!.id),
                      feature: state.selectedFeature!,
                      onClose: () {
                        HapticFeedback.lightImpact();
                        context
                            .read<MapBloc>()
                            .add(const SelectFeatureEvent(null));
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedBottomNav,
          onTap: (index) {
            setState(() {
              _selectedBottomNav = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF065F46),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map_rounded),
              label: 'Peta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.layers_outlined),
              activeIcon: Icon(Icons.layers_rounded),
              label: 'Layer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.table_chart_outlined),
              activeIcon: Icon(Icons.table_chart_rounded),
              label: 'Data',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String categoryKey) {
    final bool isSelected = _activeCategoryFilter == categoryKey;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            _activeCategoryFilter = categoryKey;
          });
          final state = context.read<MapBloc>().state;
          if (state.layer != null) {
            _renderGeoLayer(state.layer!.features);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF065F46) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF065F46)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF34D399) : const Color(0xFF059669),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
