import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static String get geoMapIdBaseUrl => dotenv.get(
        'GEO_MAPID_BASE_URL',
        fallback: 'https://geoserver.mapid.io/layers_new/get_layer',
      );

  static String get geoMapIdApiKey => dotenv.get(
        'GEO_MAPID_API_KEY',
        fallback: '',
      );

  static String get geoMapIdLayerId => dotenv.get(
        'GEO_MAPID_LAYER_ID',
        fallback: '6aaa479abf51a2f0185a601b',
      );

  static String get geoMapIdProjectId => dotenv.get(
        'GEO_MAPID_PROJECT_ID',
        fallback: '6aa3b36388f2c84b0c10cb58',
      );

  static String get openFreeMapStyleUrl => dotenv.get(
        'OPENFREEMAP_STYLE_URL',
        fallback: 'https://tiles.openfreemap.org/styles/liberty',
      );

  // Default coordinate (Yogyakarta City center)
  static const double defaultLatitude = -7.797068;
  static const double defaultLongitude = 110.370529;
  static const double defaultZoom = 13.0;
}
