import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/data/services/photo_service.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  _PhotosScreenState createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  final PhotoService _photoService = PhotoService();
  List<dynamic> photos = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    try {
      final data = await _photoService.getPhotos();
      setState(() {
        photos = data;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
      ),
      body: error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MdiIcons.camera, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Erreur lors du chargement : $error',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            )
          : photos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(MdiIcons.camera, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucune photo trouvée',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return ListTile(
                      title: Text('Photo ${photo['id']?.toString() ?? 'N/A'}'),
                      subtitle: Text(
                          'Maison ID: ${photo['maison_id']?.toString() ?? 'N/A'}'),
                      onTap: () {
                        print('Clic sur photo ${photo['id']}');
                      },
                    );
                  },
                ),
    );
  }
}
