import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/services/injection_container.dart';
import '../core/theme/app_theme.dart';
import '../features/map_viewer/presentation/bloc/map_bloc.dart';
import '../features/map_viewer/presentation/pages/splash_screen.dart';

class GeoMapApp extends StatelessWidget {
  const GeoMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MapBloc>(
          create: (_) => sl<MapBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'GEO MAPID Viewer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
