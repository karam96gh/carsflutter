import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerWidget extends StatelessWidget {
  final Function(List<File>) onImagesSelected;
  final int maxImages;

  const ImagePickerWidget({
    Key? key,
    required this.onImagesSelected,
    this.maxImages = 5,
  }) : super(key: key);

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();

    try {
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        // التحقق من عدم تجاوز الحد الأقصى
        final imagesToUse = images.length > maxImages ? images.sublist(0, maxImages) : images;
        final List<File> fileImages = imagesToUse.map((xFile) => File(xFile.path)).toList();

        if (images.length > maxImages) {
          debugPrint('تم اختيار ${images.length} صورة، لكن سيتم استخدام $maxImages فقط');
        }

        onImagesSelected(fileImages);
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        onImagesSelected([File(photo.path)]);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.photo_library),
            label: const Text('معرض الصور'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _takePicture,
            icon: const Icon(Icons.camera_alt),
            label: const Text('التقاط صورة'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}