import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'dart:io'; // For SocketException

class TmdbService {
  static const String _apiKey =
      '575db90e1dd58e6006ad7be6ded0859b'; // Replace with your valid TMDb API key
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.parse(
      '$_baseUrl/search/multi?query=$query&include_adult=false&language=en-US&page=1&api_key=$_apiKey',
    );
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint('Attempt $attempt: Making API request to: $url');
        final response =
            await http.get(url).timeout(const Duration(seconds: 10));
        debugPrint('API response status: ${response.statusCode}');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          debugPrint('API response data: $data');
          return (data['results'] as List)
              .where((item) =>
                  item['media_type'] == 'movie' || item['media_type'] == 'tv')
              .map((json) {
            debugPrint('Parsing movie: ${json['title'] ?? json['name']}');
            return Movie.fromJson(json);
          }).toList();
        } else if (response.statusCode == 429) {
          debugPrint('Rate limit hit, retrying after delay...');
          await Future.delayed(_retryDelay * attempt);
          continue;
        } else {
          debugPrint('API error: ${response.statusCode} - ${response.body}');
          throw Exception(
              'API error: ${response.statusCode} - ${response.body}');
        }
      } on SocketException catch (e) {
        debugPrint('SocketException on attempt $attempt: $e');
        if (attempt == _maxRetries) {
          throw Exception('Connection failed after $_maxRetries attempts: $e');
        }
        await Future.delayed(_retryDelay * attempt);
      } catch (e) {
        debugPrint('Network error on attempt $attempt: $e');
        if (attempt == _maxRetries) {
          throw Exception('Network error after $_maxRetries attempts: $e');
        }
        await Future.delayed(_retryDelay * attempt);
      }
    }
    throw Exception('Failed to fetch movies after $_maxRetries attempts');
  }

  static String? getImageUrl(String? posterPath) {
    return posterPath != null ? '$_imageBaseUrl$posterPath' : null;
  }
}
