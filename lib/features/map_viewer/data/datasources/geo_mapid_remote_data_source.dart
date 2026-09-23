import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/geo_feature_model.dart';

abstract class GeoMapIdRemoteDataSource {
  Future<GeoLayerModel> fetchLayer({
    required String apiKey,
    required String layerId,
    required String projectId,
  });
}

class GeoMapIdRemoteDataSourceImpl implements GeoMapIdRemoteDataSource {
  final ApiClient apiClient;

  GeoMapIdRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<GeoLayerModel> fetchLayer({
    required String apiKey,
    required String layerId,
    required String projectId,
  }) async {
    try {
      final response = await apiClient.get(
        AppConstants.geoMapIdBaseUrl,
        queryParameters: {
          'api_key': apiKey,
          'layer_id': layerId,
          'project_id': projectId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data =
            response.data is Map<String, dynamic>
                ? response.data as Map<String, dynamic>
                : Map<String, dynamic>.from(response.data as Map);

        return GeoLayerModel.fromJson(data);
      } else {
        throw ServerException(
          message: 'Gagal memuat data dari server GEO MAPID',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Terjadi kesalahan jaringan atau server: $e');
    }
  }
}
