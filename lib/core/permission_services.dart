import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestGalleryPermission() async {
    var status = await Permission.photos.request(); // iOS
    if (status.isDenied || status.isPermanentlyDenied) {
      // For Android use storage/media
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }
}
