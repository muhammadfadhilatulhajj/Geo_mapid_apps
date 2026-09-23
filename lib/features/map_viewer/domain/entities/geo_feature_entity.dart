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
  final String geometryType;
  final String contributorName;
  final String contributorFullName;
  final String contributorId;
  final Map<String, dynamic> rawProperties;
  final Map<String, dynamic> fullJson;

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
    required this.geometryType,
    required this.contributorName,
    required this.contributorFullName,
    required this.contributorId,
    required this.rawProperties,
    required this.fullJson,
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
        geometryType,
        contributorName,
        contributorFullName,
        contributorId,
        rawProperties,
        fullJson,
      ];
}

class GeoLayerEntity extends Equatable {
  final String layerId;
  final String layerName;
  final List<Map<String, dynamic>> fields;
  final List<GeoFeatureEntity> features;
  final Map<String, dynamic> fullLayerJson;

  const GeoLayerEntity({
    required this.layerId,
    required this.layerName,
    required this.fields,
    required this.features,
    required this.fullLayerJson,
  });

  @override
  List<Object?> get props => [
        layerId,
        layerName,
        fields,
        features,
        fullLayerJson,
      ];
}
