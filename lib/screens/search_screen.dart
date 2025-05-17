import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../models/movie.dart';
import 'movie_screen.dart';
import '../services/tmdb_service.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search movies...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      context
                          .read<MovieBloc>()
                          .add(SearchMovies(controller.text));
                    }
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<MovieBloc>().add(SearchMovies(value));
                }
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<MovieBloc, MovieState>(
              builder: (context, state) {
                if (state is MovieLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MovieLoaded) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 3 : 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: state.movies.length,
                    itemBuilder: (context, index) {
                      final movie = state.movies[index];
                      return MovieCard(movie: movie);
                    },
                  );
                } else if (state is MovieError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              context
                                  .read<MovieBloc>()
                                  .add(SearchMovies(controller.text));
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(
                    child: Text('Enter a search query to find movies'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieScreen(movie: movie),
          ),
        );
      },
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: movie.posterPath != null
                  ? Image.network(
                      TmdbService.getImageUrl(movie.posterPath)!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    )
                  : const Center(child: Icon(Icons.movie, size: 50)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                movie.title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
