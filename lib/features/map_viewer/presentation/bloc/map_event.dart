import 'package:equatable/equatable.dart';
import '../../domain/entities/geo_feature_entity.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeoLayerEvent extends MapEvent {
  const LoadGeoLayerEvent();
}

class GetUserLocationEvent extends MapEvent {
  const GetUserLocationEvent();
}

class SelectFeatureEvent extends MapEvent {
  final GeoFeatureEntity? feature;

  const SelectFeatureEvent(this.feature);

  @override
  List<Object?> get props => [feature];
}
