import 'package:image_picker/image_picker.dart';

import '../enums/image_source_option.dart';
import '../interface/image_picker_interface.dart';

/// [ImagePickerService] auf Basis des `image_picker`-Plugins, also der
/// echten Kamera bzw. Galerie des Geraets.
class DeviceImagePicker implements ImagePickerService {
  DeviceImagePicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Aufnahmen werden verkleinert und leicht komprimiert, damit die im
  /// Upload-Feld angekuendigten 2 MB nicht gesprengt werden.
  static const double _maxDimension = 1600;
  static const int _quality = 85;

  @override
  Future<XFile?> pickImage(ImageSourceOption source) {
    return _picker.pickImage(
      source: switch (source) {
        ImageSourceOption.camera => ImageSource.camera,
        ImageSourceOption.gallery => ImageSource.gallery,
      },
      maxWidth: _maxDimension,
      maxHeight: _maxDimension,
      imageQuality: _quality,
    );
  }
}
