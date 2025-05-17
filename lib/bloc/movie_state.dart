import '../models/movie.dart';

abstract class MovieState {}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<Movie> movies;
  final bool isSearchResult;

  MovieLoaded(this.movies, {this.isSearchResult = true});
}

class MovieError extends MovieState {
  final String message;
  MovieError(this.message);
}
