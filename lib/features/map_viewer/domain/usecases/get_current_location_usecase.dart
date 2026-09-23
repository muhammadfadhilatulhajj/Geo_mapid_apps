import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/map_repository.dart';

class GetCurrentUserLocationUseCase {
  final MapRepository repository;

  GetCurrentUserLocationUseCase(this.repository);

  Future<Either<Failure, (double latitude, double longitude)>> call() async {
    return await repository.getCurrentUserLocation();
  }
}
