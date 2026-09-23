import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/geo_feature_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/geo_mapid_remote_data_source.dart';

class MapRepositoryImpl implements MapRepository {
  final GeoMapIdRemoteDataSource remoteDataSource;
  final LocationService locationService;

  MapRepositoryImpl({
    required this.remoteDataSource,
    required this.locationService,
  });

  @override
  Future<Either<Failure, GeoLayerEntity>> getGeoMapIdLayer({
    required String apiKey,
    required String layerId,
    required String projectId,
  }) async {
    try {
      final result = await remoteDataSource.fetchLayer(
        apiKey: apiKey,
        layerId: layerId,
        projectId: projectId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal memproses data layer: $e'));
    }
  }

  @override
  Future<Either<Failure, (double latitude, double longitude)>>
      getCurrentUserLocation() async {
    try {
      final position = await locationService.getCurrentPosition();
      return Right((position.latitude, position.longitude));
    } on LocationException catch (e) {
      return Left(LocationFailure(e.message));
    } catch (e) {
      return Left(LocationFailure('Gagal mendapatkan lokasi: $e'));
    }
  }
}
