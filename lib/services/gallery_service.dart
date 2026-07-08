// lib/services/gallery_service.dart
//
// Simpan hasil output ke galeri HP (Movies/Kythera).
// Wrap gallery_saver package supaya UI tidak tahu detail platform.
//
import 'package:gallery_saver/gallery_saver.dart';

class GalleryService {
  /// Simpan file video ke galeri. Return true jika berhasil.
  static Future<bool> saveVideo(String filePath) async {
    try {
      final result = await GallerySaver.saveVideo(filePath, albumName: 'Kythera');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
