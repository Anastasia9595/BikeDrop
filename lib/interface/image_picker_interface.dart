import 'package:image_picker/image_picker.dart';
import '../enums/image_source_option.dart';

/// Kapselt den Zugriff auf Kamera und Galerie, damit die UI nicht direkt
/// vom Plugin abhaengt und in Tests ersetzt werden kann.
abstract class ImagePickerService {
  Future<XFile?> pickImage(ImageSourceOption source);
}
