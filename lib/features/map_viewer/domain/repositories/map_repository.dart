import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/geo_feature_entity.dart';

abstract class MapRepository {
  Future<Either<Failure, GeoLayerEntity>> getGeoMapIdLayer({
    required String apiKey,
    required String layerId,
    required String projectId,
  });

  Future<Either<Failure, (double latitude, double longitude)>> getCurrentUserLocation();
}
