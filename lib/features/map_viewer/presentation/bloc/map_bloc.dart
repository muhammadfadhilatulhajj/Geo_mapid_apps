import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/get_geo_layer_usecase.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetGeoLayerUseCase getGeoLayerUseCase;
  final GetCurrentUserLocationUseCase getCurrentUserLocationUseCase;

  MapBloc({
    required this.getGeoLayerUseCase,
    required this.getCurrentUserLocationUseCase,
  }) : super(const MapState()) {
    on<LoadGeoLayerEvent>(_onLoadGeoLayer);
    on<GetUserLocationEvent>(_onGetUserLocation);
    on<SelectFeatureEvent>(_onSelectFeature);
  }

  Future<void> _onLoadGeoLayer(
    LoadGeoLayerEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(status: MapStatus.loading));

    final params = GetGeoLayerParams(
      apiKey: AppConstants.geoMapIdApiKey,
      layerId: AppConstants.geoMapIdLayerId,
      projectId: AppConstants.geoMapIdProjectId,
    );

    final result = await getGeoLayerUseCase(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MapStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (layer) => emit(
        state.copyWith(
          status: MapStatus.loaded,
          layer: layer,
        ),
      ),
    );
  }

  Future<void> _onGetUserLocation(
    GetUserLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLocatingUser: true));

    final result = await getCurrentUserLocationUseCase();

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLocatingUser: false,
          errorMessage: failure.message,
        ),
      ),
      (coords) => emit(
        state.copyWith(
          isLocatingUser: false,
          userLocation: coords,
        ),
      ),
    );
  }

  void _onSelectFeature(
    SelectFeatureEvent event,
    Emitter<MapState> emit,
  ) {
    if (event.feature == null) {
      emit(state.copyWith(clearSelectedFeature: true));
    } else {
      emit(state.copyWith(selectedFeature: event.feature));
    }
  }
}
