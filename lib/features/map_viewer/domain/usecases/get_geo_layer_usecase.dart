import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/geo_feature_entity.dart';
import '../repositories/map_repository.dart';

class GetGeoLayerParams {
  final String apiKey;
  final String layerId;
  final String projectId;

  const GetGeoLayerParams({
    required this.apiKey,
    required this.layerId,
    required this.projectId,
  });
}

class GetGeoLayerUseCase {
  final MapRepository repository;

  GetGeoLayerUseCase(this.repository);

  Future<Either<Failure, GeoLayerEntity>> call(GetGeoLayerParams params) async {
    return await repository.getGeoMapIdLayer(
      apiKey: params.apiKey,
      layerId: params.layerId,
      projectId: params.projectId,
    );
  }
}
