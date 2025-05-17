import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../models/movie.dart';
import 'movie_screen.dart';
import '../services/tmdb_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Load trending movies when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieBloc>().add(LoadTrendingMovies());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search movies...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _performSearch(_controller.text),
                ),
                prefixIcon: const Icon(Icons.movie),
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _performSearch,
              onChanged: (value) {
                // Use debounced search if you want to search as the user types
                // context.read<MovieBloc>().add(DebouncedSearchMovies(value));
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<MovieBloc, MovieState>(
              listener: (context, state) {
                if (state is MovieLoaded && state.isSearchResult) {
                  _hasSearched = true;
                }
              },
              builder: (context, state) {
                if (state is MovieLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading...'),
                      ],
                    ),
                  );
                } else if (state is MovieLoaded) {
                  return _buildMovieList(state, isTablet);
                } else if (state is MovieError) {
                  return _buildErrorView(state.message);
                }
                return _buildInitialView();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieList(MovieLoaded state, bool isTablet) {
    final header = state.isSearchResult ? 'Search Results' : 'Trending Today';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            header,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
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
          ),
        ),
      ],
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_hasSearched) ...[
            const Icon(Icons.search, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Search for movies or TV shows',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<MovieBloc>().add(LoadTrendingMovies());
              },
              child: const Text('Load Trending Movies'),
            ),
          ] else ...[
            const Icon(Icons.movie_filter, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No results to display',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _performSearch(_controller.text),
                child: const Text('Try Again'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<MovieBloc>().add(LoadTrendingMovies());
                },
                child: const Text('Load Trending'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<MovieBloc>().add(SearchMovies(query));
      FocusScope.of(context).unfocus(); // Hide keyboard
    }
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPosterImage(),
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

  Widget _buildPosterImage() {
    return movie.posterPath != null
        ? Image.network(
            TmdbService.getImageUrl(movie.posterPath)!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, size: 50),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          )
        : const Center(
            child: Icon(Icons.movie, size: 50),
          );
  }
}
