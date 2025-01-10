import 'package:flutter/material.dart';
import 'video_player_page.dart'; // Import VideoPlayerPage

class ReelsPage extends StatelessWidget {
  ReelsPage({super.key});

  // Data video
  final List<Map<String, String>> videoData = [
    {
      "title": "Perkenalan Flutter SDK",
      "thumbnail": "https://img.youtube.com/vi/jYPsr5mcdS8/0.jpg",
      "videoUrl": "https://www.youtube.com/watch?v=jYPsr5mcdS8"
    },
    {
      "title": "FLUTTER - TUTORIAL by Bauroziq",
      "thumbnail": "https://img.youtube.com/vi/Mu70YL4Q8Jg/0.jpg",
      "videoUrl": "https://www.youtube.com/watch?v=Mu70YL4Q8Jg"
    },
    {
      "title": "Tutorial Dart by Programmer Zaman Now",
      "thumbnail": "https://img.youtube.com/vi/-mzXdI27tyk/0.jpg",
      "videoUrl": "https://www.youtube.com/watch?v=-mzXdI27tyk"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: videoData.length,
        itemBuilder: (context, index) {
          final video = videoData[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: GestureDetector(
              onTap: () {
                final videoId =
                    Uri.parse(video['videoUrl']!).queryParameters['v'];
                if (videoId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerPage(videoId: videoId),
                    ),
                  );
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      video['title']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      video['thumbnail']!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
