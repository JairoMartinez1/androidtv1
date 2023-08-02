import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Requerido para conectar WebSocketChannel
  runApp(MovieApp());
}

class MovieApp extends StatelessWidget {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.100.7'), // Reemplaza con la URL del WebSocket de tu dispositivo Android TV
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MovieListScreen(channel: channel),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  final WebSocketChannel channel;

  MovieListScreen({required this.channel});

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final String apiKey = '0cc7a2b1b7133d80c993c0bc3c0a847e';
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String imagePath = 'https://image.tmdb.org/t/p/w400';
  final String youtubeApiKey = 'AIzaSyApENMAAi1evpQlcrUS0wUqdzAQJRff_L4';

  List<Map<String, dynamic>> movies = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/popular?api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          movies = List.from(jsonData['results']);
        });
      } else {
        print('Error al cargar las películas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Películas'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 9 / 16,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return MovieListItem(
            title: movie['title'],
            description: movie['overview'],
            imageUrl: '$imagePath${movie['poster_path']}',
            youtubeVideoId: 'J6VNel82OEs', // Reemplaza con el ID de YouTube de la película
            channel: widget.channel,
            youtubeApiKey: youtubeApiKey,
          );
        },
      ),
    );
  }
}

class MovieListItem extends StatefulWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String youtubeVideoId;
  final WebSocketChannel channel;
  final String youtubeApiKey;

  MovieListItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.youtubeVideoId,
    required this.channel,
    required this.youtubeApiKey,
  });

  @override
  _MovieListItemState createState() => _MovieListItemState();
}

class _MovieListItemState extends State<MovieListItem> {
  final FocusNode _focusNode = FocusNode();
  Color _borderColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        setState(() {
          _borderColor = hasFocus ? Colors.blue : Colors.transparent;
        });
      },
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(
                title: widget.title,
                description: widget.description,
                imageUrl: widget.imageUrl,
                youtubeVideoId: widget.youtubeVideoId,
                channel: widget.channel,
                youtubeApiKey: widget.youtubeApiKey,
              ),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: _borderColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(widget.imageUrl, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovieDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String youtubeVideoId;
  final WebSocketChannel channel;
  final String youtubeApiKey;

  MovieDetailScreen({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.youtubeVideoId,
    required this.channel,
    required this.youtubeApiKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: youtubeVideoId,
                    flags: YoutubePlayerFlags(
                      autoPlay: true,
                      mute: false,
                      hideControls: false,
                    ),
                  ),
                  showVideoProgressIndicator: true,
                ),
              ),
              SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
