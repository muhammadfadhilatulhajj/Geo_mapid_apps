import 'package:equatable/equatable.dart';

class GeoFeatureEntity extends Equatable {
  final String id;
  final double latitude;
  final double longitude;
  final String name;
  final String address;
  final String province;
  final String regencyCity;
  final String district;
  final String village;
  final String period;
  final Map<String, dynamic> rawProperties;

  const GeoFeatureEntity({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.address,
    required this.province,
    required this.regencyCity,
    required this.district,
    required this.village,
    required this.period,
    required this.rawProperties,
  });

  @override
  List<Object?> get props => [
        id,
        latitude,
        longitude,
        name,
        address,
        province,
        regencyCity,
        district,
        village,
        period,
        rawProperties,
      ];
}

class GeoLayerEntity extends Equatable {
  final String layerId;
  final String layerName;
  final List<GeoFeatureEntity> features;

  const GeoLayerEntity({
    required this.layerId,
    required this.layerName,
    required this.features,
  });

  @override
  List<Object?> get props => [layerId, layerName, features];
}
