import 'package:flutter/material.dart';
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
    final feature = _featuresById[circle.id];
    if (feature != null) {
      context.read<MapBloc>().add(SelectFeatureEvent(feature));
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(feature.latitude, feature.longitude),
          15.0,
        ),
      );
    }
  }

  Future<void> _renderGeoLayer(List<GeoFeatureEntity> features) async {
    if (_mapController == null) return;

    _featuresById.clear();
    await _mapController?.clearCircles();

    for (final feature in features) {
      final circle = await _mapController?.addCircle(
        CircleOptions(
          geometry: LatLng(feature.latitude, feature.longitude),
          circleColor: '#1E88E5',
          circleRadius: 8.0,
          circleStrokeWidth: 2.5,
          circleStrokeColor: '#FFFFFF',
          circleOpacity: 0.9,
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

    if (_userLocationCircle != null) {
      await _mapController?.updateCircle(
        _userLocationCircle!,
        CircleOptions(
          geometry: LatLng(lat, lng),
        ),
      );
    } else {
      _userLocationCircle = await _mapController?.addCircle(
        CircleOptions(
          geometry: LatLng(lat, lng),
          circleColor: '#FF5722',
          circleRadius: 10.0,
          circleStrokeWidth: 3.0,
          circleStrokeColor: '#FFFFFF',
          circleOpacity: 1.0,
          draggable: false,
        ),
      );
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(lat, lng),
        15.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GEO MAPID - Pariwisata Jogja'),
        actions: [
          BlocBuilder<MapBloc, MapState>(
            builder: (context, state) {
              if (state.layer != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.layer!.features.length} Titik',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state.status == MapStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
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
              // MapLibre GL with OpenFreeMap Basemap Style
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

              // Loading overlay
              if (state.status == MapStatus.loading)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    color: Colors.white.withAlpha(242),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 14),
                          Text(
                            'Memuat layer data GEO MAPID...',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Floating Actions (GPS & Refresh)
              Positioned(
                right: 16,
                bottom: state.selectedFeature != null ? 240 : 24,
                child: MapFloatingActions(
                  isLocating: state.isLocatingUser,
                  onRefreshPressed: () {
                    context.read<MapBloc>().add(const LoadGeoLayerEvent());
                  },
                  onMyLocationPressed: () {
                    context.read<MapBloc>().add(const GetUserLocationEvent());
                  },
                ),
              ),

              // Selected Feature Detail Sheet / Popup
              if (state.selectedFeature != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FeatureDetailSheet(
                    feature: state.selectedFeature!,
                    onClose: () {
                      context
                          .read<MapBloc>()
                          .add(const SelectFeatureEvent(null));
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
