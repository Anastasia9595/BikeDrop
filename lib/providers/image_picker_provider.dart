import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interface/image_picker_interface.dart';
import '../repository/device_image_picker.dart';

/// Zugriff auf Kamera/Galerie. In Tests per `overrideWithValue` durch
/// eine Fake-Implementierung ersetzbar.
final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return DeviceImagePicker();
});
