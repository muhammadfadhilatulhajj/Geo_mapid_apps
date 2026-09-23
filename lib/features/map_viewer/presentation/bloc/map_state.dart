import 'package:equatable/equatable.dart';
import '../../domain/entities/geo_feature_entity.dart';

enum MapStatus { initial, loading, loaded, error }

class MapState extends Equatable {
  final MapStatus status;
  final GeoLayerEntity? layer;
  final GeoFeatureEntity? selectedFeature;
  final (double lat, double lng)? userLocation;
  final bool isLocatingUser;
  final String? errorMessage;

  const MapState({
    this.status = MapStatus.initial,
    this.layer,
    this.selectedFeature,
    this.userLocation,
    this.isLocatingUser = false,
    this.errorMessage,
  });

  MapState copyWith({
    MapStatus? status,
    GeoLayerEntity? layer,
    GeoFeatureEntity? selectedFeature,
    bool clearSelectedFeature = false,
    (double lat, double lng)? userLocation,
    bool? isLocatingUser,
    String? errorMessage,
  }) {
    return MapState(
      status: status ?? this.status,
      layer: layer ?? this.layer,
      selectedFeature: clearSelectedFeature
          ? null
          : (selectedFeature ?? this.selectedFeature),
      userLocation: userLocation ?? this.userLocation,
      isLocatingUser: isLocatingUser ?? this.isLocatingUser,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        layer,
        selectedFeature,
        userLocation,
        isLocatingUser,
        errorMessage,
      ];
}
