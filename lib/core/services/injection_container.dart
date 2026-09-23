import 'package:get_it/get_it.dart';
import '../../features/map_viewer/data/datasources/geo_mapid_remote_data_source.dart';
import '../../features/map_viewer/data/repositories/map_repository_impl.dart';
import '../../features/map_viewer/domain/repositories/map_repository.dart';
import '../../features/map_viewer/domain/usecases/get_current_location_usecase.dart';
import '../../features/map_viewer/domain/usecases/get_geo_layer_usecase.dart';
import '../../features/map_viewer/presentation/bloc/map_bloc.dart';
import '../network/api_client.dart';
import 'location_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // BLoC
  sl.registerFactory(
    () => MapBloc(
      getGeoLayerUseCase: sl(),
      getCurrentUserLocationUseCase: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetGeoLayerUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserLocationUseCase(sl()));

  // Repository
  sl.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(
      remoteDataSource: sl(),
      locationService: sl(),
    ),
  );

  // DataSources
  sl.registerLazySingleton<GeoMapIdRemoteDataSource>(
    () => GeoMapIdRemoteDataSourceImpl(apiClient: sl()),
  );

  // Core Services
  sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
}
