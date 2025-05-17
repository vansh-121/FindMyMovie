import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieScreen extends StatelessWidget {
  final Movie movie;

  const MovieScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define gradient colors based on theme
    final List<Color> gradientColors = isDarkMode
        ? [
            Colors.black,
            const Color(0xFF101010),
            const Color(0xFF101010),
          ]
        : [
            Colors.white,
            const Color(0xFFF5F5F5),
            const Color(0xFFF5F5F5),
          ];

    // Define text colors based on theme
    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color secondaryTextColor =
        isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
    final Color iconButtonColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final Color borderColor =
        isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;
    final Color chipColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors,
              ),
            ),
          ),

          // Movie Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie Poster Section with Backdrop
                Stack(
                  children: [
                    // Backdrop with overlay
                    _buildPosterBackdrop(size, isDarkMode),

                    // Content Stack (back button, poster, age rating)
                    Column(
                      children: [
                        // App Bar Area with Back Button
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Back Button
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.5)
                                          : Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                ),

                                // Watchlist Button
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.black.withOpacity(0.5)
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.bookmark_border,
                                    color: primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Centered Movie Poster
                        SizedBox(
                          width: double.infinity,
                          height: isTablet ? 400 : 300,
                          child: Center(
                            child: _buildPoster(150, isTablet ? 225 : 180),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Movie Details Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Center(
                        child: Text(
                          movie.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Rating and Year Row
                      _buildInfoRow(
                          primaryTextColor, secondaryTextColor, borderColor),

                      const SizedBox(height: 24),

                      // Action Buttons
                      _buildActionButtons(
                          isDarkMode, iconButtonColor, secondaryTextColor),

                      const SizedBox(height: 24),

                      // Overview Section
                      _buildOverviewSection(
                          primaryTextColor, secondaryTextColor, chipColor),

                      const SizedBox(height: 24),

                      // Cast Section (Placeholder)
                      _buildCastSection(primaryTextColor, secondaryTextColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Poster backdrop with gradient overlay
  Widget _buildPosterBackdrop(Size size, bool isDarkMode) {
    final Color overlayColor = isDarkMode ? Colors.black : Colors.white;
    final List<Color> gradientColors = isDarkMode
        ? [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.8),
            Colors.black,
          ]
        : [
            Colors.transparent,
            Colors.transparent,
            Colors.white.withOpacity(0.8),
            Colors.white,
          ];

    return Container(
      width: double.infinity,
      height: size.height * 0.5,
      decoration: BoxDecoration(
        // Use poster as background
        image: movie.posterPath != null
            ? DecorationImage(
                image: NetworkImage(
                  TmdbService.getImageUrl(movie.posterPath)!,
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  overlayColor.withOpacity(0.65),
                  BlendMode.darken,
                ),
              )
            : null,
        color: isDarkMode ? Colors.black : Colors.white,
      ),
      // Bottom gradient for smoother transition
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
            stops: const [0.0, 0.5, 0.8, 1.0],
          ),
        ),
      ),
    );
  }

  // Poster image
  Widget _buildPoster(double width, double height) {
    if (movie.posterPath == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.movie, size: 80, color: Colors.white70),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          TmdbService.getImageUrl(movie.posterPath)!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade800,
            child:
                const Icon(Icons.broken_image, size: 80, color: Colors.white70),
          ),
        ),
      ),
    );
  }

  // Info row with year, rating, runtime
  Widget _buildInfoRow(
      Color textColor, Color secondaryTextColor, Color borderColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Release Year
        if (movie.releaseDate != null && movie.releaseDate!.isNotEmpty) ...[
          Text(
            movie.releaseDate!.substring(0, 4),
            style: TextStyle(
              fontSize: 16,
              color: secondaryTextColor,
            ),
          ),
          _buildDot(borderColor),
        ],

        // Age Rating (16+)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '16+',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ),

        _buildDot(borderColor),

        // HD Quality
        Text(
          'HD',
          style: TextStyle(
            fontSize: 16,
            color: secondaryTextColor,
          ),
        ),

        _buildDot(borderColor),

        // IMDB Rating
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              '7.4',
              style: TextStyle(
                fontSize: 16,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),

        _buildDot(borderColor),

        // CC (Closed Captioning)
        Text(
          'CC',
          style: TextStyle(
            fontSize: 16,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }

  // Small dot separator
  Widget _buildDot(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '•',
        style: TextStyle(
          color: color,
          fontSize: 16,
        ),
      ),
    );
  }

  // Action buttons (Play, Trailer, Download)
  Widget _buildActionButtons(
      bool isDarkMode, Color iconButtonColor, Color labelColor) {
    return Row(
      children: [
        // Play Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Trailer Button
        _buildIconButton(
            Icons.slideshow, 'Trailer', iconButtonColor, labelColor),

        const SizedBox(width: 12),

        // Download Button
        _buildIconButton(
            Icons.download, 'Download', iconButtonColor, labelColor),
      ],
    );
  }

  // Icon button with label
  Widget _buildIconButton(
      IconData icon, String label, Color iconButtonColor, Color labelColor) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconButtonColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Overview section
  Widget _buildOverviewSection(
      Color titleColor, Color textColor, Color chipColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movie.overview,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            _buildGenreChip('Action', chipColor),
            _buildGenreChip('Thriller', chipColor),
            _buildGenreChip('Crime', chipColor),
          ],
        ),
      ],
    );
  }

  // Genre chips
  Widget _buildGenreChip(String genre, Color chipColor) {
    return Chip(
      label: Text(genre),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  // Cast section (placeholder)
  Widget _buildCastSection(Color titleColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Starring',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Denzel Washington, Dakota Fanning, Eugenio Mastrandrea, David Denman, Gaia Scodellaro',
          style: TextStyle(
            fontSize: 16,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Creator: ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            Text(
              'Antoine Fuqua, Richard Wenk',
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
