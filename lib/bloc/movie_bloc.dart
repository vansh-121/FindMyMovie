import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/tmdb_service.dart';
import 'movie_event.dart';
import 'movie_state.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final TmdbService tmdbService;
  Timer? _debounce;

  MovieBloc({required this.tmdbService}) : super(MovieInitial()) {
    on<SearchMovies>((event, emit) async {
      // Cancel any previous search requests
      _debounce?.cancel();

      // Validate input
      if (event.query.trim().isEmpty) {
        emit(MovieError('Please enter a search term'));
        return;
      }

      // Show loading state immediately
      emit(MovieLoading());

      try {
        debugPrint('Starting search for: ${event.query}');

        // Perform the search
        final movies = await tmdbService.searchMovies(event.query);

        // Check if the response is valid
        if (movies.isEmpty) {
          debugPrint('No movies found for query: ${event.query}');
          emit(MovieError('No results found for "${event.query}"'));
        } else {
          debugPrint('Found ${movies.length} movies for query: ${event.query}');
          emit(MovieLoaded(movies));
        }
      } catch (e) {
        debugPrint('Error during search: $e');
        emit(MovieError('Failed to load movies: $e'));
      }
    });

    // Add debounced search event handler
    on<DebouncedSearchMovies>((event, emit) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () {
        add(SearchMovies(event.query));
      });
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
