class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String overview;
  final String? releaseDate;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.overview,
    this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? 'Unknown',
      posterPath: json['poster_path'],
      overview: json['overview'] ?? 'No overview available',
      releaseDate: json['release_date'] ?? json['first_air_date'],
    );
  }
}
