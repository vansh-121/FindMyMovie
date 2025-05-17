abstract class MovieEvent {}

class SearchMovies extends MovieEvent {
  final String query;
  SearchMovies(this.query);
}

// New event for debounced search
class DebouncedSearchMovies extends MovieEvent {
  final String query;
  DebouncedSearchMovies(this.query);
}
