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
    required super.geometryType,
    required super.contributorName,
    required super.contributorFullName,
    required super.contributorId,
    required super.rawProperties,
    required super.fullJson,
  });

  factory GeoFeatureModel.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String? ?? '';
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? [0.0, 0.0];
    final geometryType = geometry['type'] as String? ?? 'Point';

    // GeoJSON coordinate format: [longitude, latitude]
    final double lng = (coordinates.isNotEmpty)
        ? (coordinates[0] as num).toDouble()
        : 0.0;
    final double lat = (coordinates.length > 1)
        ? (coordinates[1] as num).toDouble()
        : 0.0;

    final properties = json['properties'] as Map<String, dynamic>? ?? {};
    final user = json['user'] as Map<String, dynamic>? ?? {};

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
      geometryType: geometryType,
      contributorName: user['name'] as String? ?? '-',
      contributorFullName: user['full_name'] as String? ?? '-',
      contributorId: user['_id'] as String? ?? '-',
      rawProperties: properties,
      fullJson: json,
    );
  }

  Map<String, dynamic> toJson() {
    return fullJson;
  }
}

class GeoLayerModel extends GeoLayerEntity {
  const GeoLayerModel({
    required super.layerId,
    required super.layerName,
    required super.fields,
    required super.features,
    required super.fullLayerJson,
  });

  factory GeoLayerModel.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'] as List<dynamic>? ?? [];
    final List<GeoFeatureModel> parsedFeatures = rawFeatures
        .map((f) => GeoFeatureModel.fromJson(f as Map<String, dynamic>))
        .toList();

    final rawFields = json['fields'] as List<dynamic>? ?? [];
    final parsedFields = rawFields
        .map((f) => Map<String, dynamic>.from(f as Map))
        .toList();

    return GeoLayerModel(
      layerId: json['layer_id'] as String? ?? '',
      layerName: json['layer_name'] as String? ?? 'Data Layer',
      fields: parsedFields,
      features: parsedFeatures,
      fullLayerJson: json,
    );
  }
}
