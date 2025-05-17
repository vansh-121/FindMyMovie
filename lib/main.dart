import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/movie_bloc.dart';
import 'screens/search_screen.dart';
import 'services/tmdb_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindMyMovie',
      // Use system theme mode to follow the device settings
      themeMode: ThemeMode.system,
      // Light theme configuration
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        // Add any other light theme customizations here
      ),
      // Dark theme configuration
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        // Add any other dark theme customizations here
      ),
      home: BlocProvider(
        create: (context) => MovieBloc(tmdbService: TmdbService()),
        child: const SearchScreen(),
      ),
    );
  }
}
