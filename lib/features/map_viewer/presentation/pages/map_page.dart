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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(const LoadGeoLayerEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    final query = _searchQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? features
        : features.where((f) {
            return f.name.toLowerCase().contains(query) ||
                f.address.toLowerCase().contains(query) ||
                f.district.toLowerCase().contains(query) ||
                f.village.toLowerCase().contains(query);
          }).toList();

    for (final feature in filtered) {
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

    // If search returned results, fly to first match
    if (query.isNotEmpty && filtered.isNotEmpty) {
      final first = filtered.first;
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(first.latitude, first.longitude),
          14.8,
        ),
      );
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
                compassEnabled: false,
              ),

              // Clean Header & Functional Search Bar
              SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top App Header: Logo + App Name Only
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
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
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Geo MAPID',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Peta Explorer • Pariwisata Jogja',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (state.status == MapStatus.loading)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF059669),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Functional Search Bar Box
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Cari nama objek wisata, alamat...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                                if (state.layer != null) {
                                  _renderGeoLayer(state.layer!.features);
                                }
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  size: 18, color: Color(0xFF64748B)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                if (state.layer != null) {
                                  _renderGeoLayer(state.layer!.features);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tooltip Pill: "Ketuk marker detail"
              Positioned(
                top: 132,
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

              // Floating Controls Stack (North, Zoom In/Out, Refresh Layer, GPS)
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
    );
  }
}
