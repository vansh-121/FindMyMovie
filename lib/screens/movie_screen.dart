import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieScreen extends StatelessWidget {
  final Movie movie;

  const MovieScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isTablet
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPoster(context, isTablet),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDetails(context)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPoster(context, isTablet),
                    const SizedBox(height: 16),
                    _buildDetails(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPoster(BuildContext context, bool isTablet) {
    return movie.posterPath != null
        ? Image.network(
            TmdbService.getImageUrl(movie.posterPath)!,
            width: isTablet ? 200 : double.infinity,
            height: isTablet ? 300 : 400,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 100),
          )
        : const Icon(Icons.movie, size: 100);
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (movie.releaseDate != null)
          Text(
            'Release Date: ${movie.releaseDate}',
            style: const TextStyle(fontSize: 16),
          ),
        const SizedBox(height: 8),
        Text(
          movie.overview,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
