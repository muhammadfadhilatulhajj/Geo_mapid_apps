import '../../domain/entities/geo_feature_entity.dart';

class GeoFeatureModel extends GeoFeatureEntity {
  const GeoFeatureModel({
    required super.id,
    required super.latitude,
    required super.longitude,
    required super.name,
    required super.address,
    required super.province,
    required super.regencyCity,
    required super.district,
    required super.village,
    required super.period,
    required super.rawProperties,
  });

  factory GeoFeatureModel.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String? ?? '';
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? [0.0, 0.0];

    // GeoJSON coordinate format: [longitude, latitude]
    final double lng = (coordinates.isNotEmpty)
        ? (coordinates[0] as num).toDouble()
        : 0.0;
    final double lat = (coordinates.length > 1)
        ? (coordinates[1] as num).toDouble()
        : 0.0;

    final properties = json['properties'] as Map<String, dynamic>? ?? {};

    return GeoFeatureModel(
      id: id,
      latitude: lat,
      longitude: lng,
      name: properties['NAMA'] as String? ?? 'Tanpa Nama',
      address: properties['ALAMAT'] as String? ?? '-',
      province: properties['PROVINSI'] as String? ?? '-',
      regencyCity: properties['KABKOT'] as String? ?? '-',
      district: properties['KECAMATAN'] as String? ?? '-',
      village: properties['DESA'] as String? ?? '-',
      period: properties['WAKTU'] as String? ?? '-',
      rawProperties: properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'properties': rawProperties,
    };
  }
}

class GeoLayerModel extends GeoLayerEntity {
  const GeoLayerModel({
    required super.layerId,
    required super.layerName,
    required super.features,
  });

  factory GeoLayerModel.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'] as List<dynamic>? ?? [];
    final List<GeoFeatureModel> parsedFeatures = rawFeatures
        .map((f) => GeoFeatureModel.fromJson(f as Map<String, dynamic>))
        .toList();

    return GeoLayerModel(
      layerId: json['layer_id'] as String? ?? '',
      layerName: json['layer_name'] as String? ?? 'Data Layer',
      features: parsedFeatures,
    );
  }
}
