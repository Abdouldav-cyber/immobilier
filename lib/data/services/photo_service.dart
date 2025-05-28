import 'package:gestion_immo/data/services/base_service.dart';

class PhotoService extends BaseService {
  PhotoService() : super('photos');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'url': item['url'],
      'description': item['description'],
      'maison_id': item['maison_id'],
      'sup': item['sup'] ?? false,
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> createWithImage(Map<String, dynamic> data,
      {String? imagePath, required String imageField}) async {
    return super
        .createWithImage(data, imagePath: imagePath, imageField: imageField);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'url': item['url'],
      'description': item['description'],
      'maison_id': item['maison_id'],
      'sup': item['sup'] ?? false,
    };
    return super.update(id, sanitizedItem);
  }
}
