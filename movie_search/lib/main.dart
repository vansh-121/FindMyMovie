import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

// Replace with your actual TMDb API key
const String apiKey = '575db90e1dd58e6006ad7be6ded0859b';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Search',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => MovieCubit(),
        child: MovieSearchScreen(),
      ),
    );
  }
}

// Cubit States
abstract class MovieState {}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List movies;
  MovieLoaded(this.movies);
}

class MovieError extends MovieState {
  final String message;
  MovieError(this.message);
}

// Cubit
class MovieCubit extends Cubit<MovieState> {
  MovieCubit() : super(MovieInitial());

  void searchMovies(String query) async {
    if (query.isEmpty) {
      emit(MovieInitial());
      return;
    }
    emit(MovieLoading());
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.themoviedb.org/3/search/multi?query=$query&include_adult=false&language=en-US&page=1&api_key=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(MovieLoaded(data['results']));
      } else {
        emit(MovieError('Something went wrong! Code: ${response.statusCode}'));
      }
    } catch (e) {
      emit(MovieError('Failed to fetch movies: $e'));
    }
  }
}

// UI
class MovieSearchScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Movies')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search movies...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    context.read<MovieCubit>().searchMovies(_controller.text);
                  },
                ),
              ),
              onSubmitted: (value) {
                context.read<MovieCubit>().searchMovies(value);
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<MovieCubit, MovieState>(
              builder: (context, state) {
                if (state is MovieLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is MovieLoaded) {
                  final movies = state.movies;
                  if (movies.isEmpty) {
                    return Center(child: Text('No results found.'));
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth > 600;
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTablet ? 4 : 2,
                          childAspectRatio: 0.6,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: movies.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          final posterPath = movie['poster_path'];
                          return Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (posterPath != null)
                                  Image.network(
                                    'https://image.tmdb.org/t/p/w500$posterPath',
                                    fit: BoxFit.cover,
                                    height: 200,
                                    width: double.infinity,
                                  )
                                else
                                  Container(
                                    height: 200,
                                    color: Colors.grey,
                                    child: Center(child: Text('No Image')),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    movie['title'] ??
                                        movie['name'] ??
                                        'Unknown Title',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    movie['overview'] ?? '',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                } else if (state is MovieError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => context
                              .read<MovieCubit>()
                              .searchMovies(_controller.text),
                          child: Text('Retry'),
                        )
                      ],
                    ),
                  );
                }
                return Center(child: Text('Search for movies above.'));
              },
            ),
          )
        ],
      ),
    );
  }
}
