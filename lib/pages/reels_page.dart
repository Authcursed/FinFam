import 'package:flutter/material.dart';
import 'video_player_page.dart'; // Import VideoPlayerPage

class ReelsPage extends StatelessWidget {
  ReelsPage({super.key});

  // Data video
  final List<Map<String, String>> videoData = [
    {
      "title": "Cara Ngatur Duit Tanpa Ribet",
      "thumbnail": "https://img.youtube.com/vi/sCUghGYNGC4/0.jpg",
      "videoUrl": "https://www.youtube.com/watch?v=sCUghGYNGC4"
    },
    {
      "title": "15 TIPS NGATUR DUIT ALA RADITYA DIKA",
      "thumbnail": "https://img.youtube.com/vi/WmIdpjLIVMI/0.jpg",
      "videoUrl": "https://www.youtube.com/watch?v=WmIdpjLIVMI"
    },
    {
      "title": "5 Kesalahan Finansial Kami di Usia 20an",
      "thumbnail": "https://img.youtube.com/vi/iCrl9roCgg8/0.jpg",
      "videoUrl": "https://www.youtube.com/watch?v=iCrl9roCgg8"
    },
    {
      "title": "Gw 35 Tahun, Andai Umur 20an udah tau ini",
      "thumbnail": "https://img.youtube.com/vi/23qG2wQQ9QA/0.jpg",
      "videoUrl": "https://www.youtube.com/watch?v=23qG2wQQ9QA"
    },
    {
      "title": "4 Bisnis Tanpa Modal Untuk Pemula",
      "thumbnail": "https://img.youtube.com/vi/wosPSj7fF34/0.jpg",
      "videoUrl": "https://www.youtube.com/watch?v=wosPSj7fF34"
    },
    {
      "title": "Potensi Cuan Jutaan dari 5 Side Hustles Ini",
      "thumbnail": "https://img.youtube.com/vi/EJFxY_tMY70/0.jpg",
      "videoUrl": "https://www.youtube.com/watch?v=EJFxY_tMY70"
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
