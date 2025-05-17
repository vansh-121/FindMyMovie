abstract class MovieEvent {}

class SearchMovies extends MovieEvent {
  final String query;
  SearchMovies(this.query);
}
