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

  @override
  void initState() {
    super.initState();
    // Dispatch events to fetch layer on start
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

    for (final feature in features) {
      // Modern Vibrant Indigo Point with Crisp White Border
      final circle = await _mapController?.addCircle(
        CircleOptions(
          geometry: LatLng(feature.latitude, feature.longitude),
          circleColor: '#2563EB',
          circleRadius: 8.5,
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
      // Outer halo circle
      _userLocationPulseCircle = await _mapController?.addCircle(
        CircleOptions(
          geometry: target,
          circleColor: '#06B6D4',
          circleRadius: 18.0,
          circleOpacity: 0.25,
          circleStrokeWidth: 0.0,
        ),
      );

      // Inner GPS marker
      _userLocationCircle = await _mapController?.addCircle(
        CircleOptions(
          geometry: target,
          circleColor: '#0EA5E9',
          circleRadius: 9.0,
          circleStrokeWidth: 3.0,
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

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state.status == MapStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                margin: const EdgeInsets.all(16),
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
                compassEnabled: true,
              ),

              // Modern Floating Header / Search Bar Style
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withAlpha(20),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.map_rounded,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'GEO MAPID Viewer',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Pariwisata Jogja • OpenFreeMap',
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
                              color: Color(0xFF2563EB),
                            ),
                          )
                        else if (state.layer != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${state.layer!.features.length} Objek',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Floating Actions (Zoom in/out, Refresh, GPS)
              Positioned(
                right: 16,
                bottom: state.selectedFeature != null ? 310 : 32,
                child: MapFloatingActions(
                  isLocating: state.isLocatingUser,
                  onZoomInPressed: _zoomIn,
                  onZoomOutPressed: _zoomOut,
                  onRefreshPressed: () {
                    HapticFeedback.selectionClick();
                    context.read<MapBloc>().add(const LoadGeoLayerEvent());
                  },
                  onMyLocationPressed: () {
                    HapticFeedback.selectionClick();
                    context.read<MapBloc>().add(const GetUserLocationEvent());
                  },
                ),
              ),

              // Modern Floating Feature Popup Card
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
