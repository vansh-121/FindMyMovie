import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class TmdbService {
  static const String _apiKey =
      '575db90e1dd58e6006ad7be6ded0859b'; // Replace with your TMDb API key
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.parse(
      '$_baseUrl/search/multi?query=$query&include_adult=false&language=en-US&page=1&api_key=$_apiKey',
    );
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .where((item) =>
                item['media_type'] == 'movie' || item['media_type'] == 'tv')
            .map((json) => Movie.fromJson(json))
            .toList();
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static String? getImageUrl(String? posterPath) {
    return posterPath != null ? '$_imageBaseUrl$posterPath' : null;
  }
}
