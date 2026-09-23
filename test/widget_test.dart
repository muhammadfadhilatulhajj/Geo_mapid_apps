import 'package:flutter_test/flutter_test.dart';
import 'package:geo_mapid_app/features/map_viewer/data/models/geo_feature_model.dart';

void main() {
  group('GeoFeatureModel', () {
    test('should parse GeoJSON point feature correctly', () {
      final sampleJson = {
        'id': 'test-id-123',
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [110.368369, -7.799231],
        },
        'properties': {
          'NAMA': 'TAMAN TIMUR PASAR BERINGHARJO',
          'ALAMAT': 'JL. SRIWEDANI, YOGYAKARTA',
          'PROVINSI': 'DAERAH ISTIMEWA YOGYAKARTA',
          'KABKOT': 'KOTA YOGYAKARTA',
          'KECAMATAN': 'GONDOMANAN',
          'DESA': 'NGUPASAN',
          'WAKTU': 'Q2 2024',
        },
      };

      final model = GeoFeatureModel.fromJson(sampleJson);

      expect(model.id, 'test-id-123');
      expect(model.name, 'TAMAN TIMUR PASAR BERINGHARJO');
      expect(model.latitude, -7.799231);
      expect(model.longitude, 110.368369);
      expect(model.district, 'GONDOMANAN');
    });
  });
}
