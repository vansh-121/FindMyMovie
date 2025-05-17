import 'dart:async';
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
  static const Duration _retryDelay = Duration(seconds: 1);

  // HTTP client instance to reuse connections
  final http.Client _client = http.Client();

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) {
      debugPrint('Empty query provided');
      return [];
    }

    // Encode the query properly to handle special characters
    final encodedQuery = Uri.encodeComponent(query);

    final url = Uri.parse(
      '$_baseUrl/search/multi?query=$encodedQuery&include_adult=false&language=en-US&page=1&api_key=$_apiKey',
    );

    debugPrint('Preparing to search for: "$query"');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint('Attempt $attempt: Making API request to TMDb');

        // Use a longer timeout for the first attempt
        final timeout = attempt == 1
            ? const Duration(seconds: 20)
            : const Duration(seconds: 15);

        final response = await _client.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(timeout);

        debugPrint('Response status code: ${response.statusCode}');

        if (response.statusCode == 200) {
          try {
            final data = json.decode(response.body);
            debugPrint('Successfully decoded JSON response');

            if (data['results'] == null) {
              debugPrint('API returned null results array');
              return [];
            }

            final movies = (data['results'] as List)
                .where((item) =>
                    item['media_type'] == 'movie' || item['media_type'] == 'tv')
                .map((json) => Movie.fromJson(json))
                .toList();

            debugPrint('Found ${movies.length} movies/TV shows');
            return movies;
          } catch (parseError) {
            debugPrint('JSON parsing error: $parseError');
            throw Exception('Failed to parse API response: $parseError');
          }
        } else if (response.statusCode == 429) {
          // Handle rate limiting
          debugPrint('Rate limit exceeded. Waiting before retry...');
          await Future.delayed(_retryDelay * attempt);
          continue;
        } else {
          debugPrint('API error: ${response.statusCode} - ${response.body}');

          // Wait before retrying on server errors
          if (response.statusCode >= 500 && attempt < _maxRetries) {
            await Future.delayed(_retryDelay * attempt);
            continue;
          }

          throw Exception('API error: ${response.statusCode}');
        }
      } on SocketException catch (e) {
        debugPrint('Connection error on attempt $attempt: $e');
        if (attempt < _maxRetries) {
          // Exponential backoff for connection issues
          await Future.delayed(_retryDelay * attempt);
          continue;
        }
        throw Exception('Connection failed: Check your internet connection');
      } on http.ClientException catch (e) {
        debugPrint('HTTP client error on attempt $attempt: $e');
        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay * attempt);
          continue;
        }
        throw Exception('Network client error: $e');
      } on TimeoutException catch (e) {
        debugPrint('Timeout on attempt $attempt: $e');
        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay * attempt);
          continue;
        }
        throw Exception('Request timed out: Please try again');
      } catch (e) {
        debugPrint('Unexpected error on attempt $attempt: $e');
        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay * attempt);
          continue;
        }
        throw Exception('Search failed: $e');
      }
    }

    throw Exception('Failed to search movies after multiple attempts');
  }

  static String? getImageUrl(String? posterPath) {
    return posterPath != null ? '$_imageBaseUrl$posterPath' : null;
  }

  // Don't forget to close the client when done
  void dispose() {
    _client.close();
  }
}
