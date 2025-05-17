import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/tmdb_service.dart';
import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final TmdbService tmdbService;

  MovieBloc({required this.tmdbService}) : super(MovieInitial()) {
    on<SearchMovies>((event, emit) async {
      emit(MovieLoading());
      try {
        final movies = await tmdbService.searchMovies(event.query);
        if (movies.isEmpty) {
          emit(MovieError('No movies found'));
        } else {
          emit(MovieLoaded(movies));
        }
      } catch (e) {
        emit(MovieError('Failed to load movies: $e'));
      }
    });
  }
}
