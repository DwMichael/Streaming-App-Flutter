import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../api/tmdb_api.dart';

import '../../model/movie.dart';
import '../../provider/provider.dart';
import '../../widget/star_rating.dart';

class HomePage extends HookConsumerWidget {
  static const routName = "/homepage";
  final String title;

  const HomePage({Key? key, required this.title}) : super(key: key);
  static const double fontSize = 13;
  static const double paddingButton = 9;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TmdbApi tmdbApi = ref.watch(tmdbApiProvider);

    final ValueNotifier<int> selectedButton = useState(0);
    // final topRated = tmdbApi.getTopRatedMovies();

    final topRated = useFuture(useMemoized(tmdbApi.getTopRatedMovies));
    final tvPopular = useFuture(useMemoized(tmdbApi.getTvPopular));
    final trendingMovies = useFuture(useMemoized(tmdbApi.getTrendingMovies));

    final List<List<Movie>?> movieLists = [
      topRated.data,
      tvPopular.data,
      trendingMovies.data,
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D2D2D), Color(0xFF4A4A4A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            // Use a custom font for the text
            const Text(
              "Odkryj coś nowego",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto'),
            ),
            const SizedBox(
              height: 10,
            ),
            MainMoviesRow(
              fetchMovies: () => tmdbApi.getMovies(),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  // Use an icon for the button
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(paddingButton),
                    elevation: 10,
                    backgroundColor: Colors.grey,
                    // Use a custom shape for the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    selectedButton.value = 0;
                  },
                  // Use an icon for the button
                  child: const Row(
                    children: [
                      Text(
                        "Top Rated",
                        style:
                            TextStyle(fontSize: fontSize, color: Colors.black),
                      ),
                      Icon(
                        Icons.star,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(paddingButton),
                    elevation: 10,
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    selectedButton.value = 1;
                  },
                  child: const Row(
                    children: [
                      Text(
                        "TV Popular ",
                        style:
                            TextStyle(fontSize: fontSize, color: Colors.black),
                      ),
                      Icon(
                        Icons.tv,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(paddingButton),
                    elevation: 10,
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    selectedButton.value = 2;
                  },
                  child: const Row(
                    children: [
                      Text(
                        "Popular Movies ",
                        style:
                            TextStyle(fontSize: fontSize, color: Colors.black),
                      ),
                      Icon(
                        Icons.movie,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 10),
              child:
                  // Use an animation for the category column
                  AnimatedOpacity(
                opacity: selectedButton.value == null
                    ? 0.0
                    : 1.0, // Fade in or out depending on the selected button
                duration: const Duration(
                    seconds: 1), // The duration of the animation in seconds
                child: SizedBox(
                  height: 220, // The height of the category column in pixels
                  child: CategoryColumn(
                      fetchMovies: movieLists[
                          selectedButton.value]), // The widget to animate
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MainMoviesRow extends HookConsumerWidget {
  const MainMoviesRow({required this.fetchMovies, super.key});
  final Future<List<Movie>> Function() fetchMovies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movies = useFuture(useMemoized(fetchMovies));
    final current = useState(0);
    if (movies.data == null) {
      return const SizedBox(
        height: 250,
        child: Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return CarouselSlider(
        items: movies.data!
            .map(
              (item) => Container(
                width: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: CachedNetworkImageProvider(
                      'http://image.tmdb.org/t/p/w500${item.posterPath}',
                    ),
                  ),
                ),
              ),
            )
            .toList(),
        options: CarouselOptions(
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 8),
            enlargeCenterPage: true,
            aspectRatio: 1.4,
            onPageChanged: (index, reason) {
              current.value = index;
            }),
      );
    }
  }
}

class CategoryColumn extends HookConsumerWidget {
  const CategoryColumn({
    Key? key,
    required this.fetchMovies,
  }) : super(key: key);
  final List<Movie>? fetchMovies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (fetchMovies == null) {
      return const SizedBox(
        height: 250,
        child: Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: fetchMovies!.length,
              itemBuilder: (
                BuildContext context,
                int index,
              ) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    width: 125,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CachedNetworkImage(
                            fit: BoxFit.fitWidth,
                            imageUrl:
                                'http://image.tmdb.org/t/p/w500${fetchMovies![index].posterPath}',
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 22,
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                  Colors.black,
                                  Colors.transparent
                                ])),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0, bottom: 5),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child:
                                StarRating(rating: fetchMovies![index].rating),
                          ),
                        )
                      ],
                    ),
                  ),
                ).animate().fadeIn(curve: Curves.easeInOut).slideX();
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      );
    }
  }
}
