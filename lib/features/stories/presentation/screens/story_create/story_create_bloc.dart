import 'dart:io';

import 'package:biux/features/stories/data/models/story.dart';
import 'package:biux/features/stories/data/repositories/stories_firebase_repository.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image/image.dart' as img;

class StoryCreateBloc extends ChangeNotifier {
  List<AssetEntity> imgList = [];
  List<AssetEntity> entitiesList = [];
  final List<String> listTags = [];
  bool loading = false;
  int current = 0;
  final StoriesFirebaseRepository storiesFirebaseRepository =
      StoriesFirebaseRepository();
  final UserFirebaseRepository userFirebaseRepository =
      UserFirebaseRepository();

  void initialEntities({required List<AssetEntity> entitiesList}) {
    this.entitiesList = entitiesList;
    imgList = [entitiesList.first];
    notifyListeners();
  }

  void addAllEntities({required List<AssetEntity> entitiesList}) {
    this.entitiesList.addAll(entitiesList);
    notifyListeners();
  }

  void addEntity({required AssetEntity entity}) {
    entitiesList.insertAll(0, [entity]);
    notifyListeners();
  }

  void addImageSeleted({required AssetEntity image}) {
    imgList.add(image);
    notifyListeners();
  }

  void deleteImageSeleted({required AssetEntity image}) {
    imgList.removeWhere(
      (element) => element == image,
    );
    notifyListeners();
  }

  void changeCurrent({required int current}) {
    this.current = current;
    notifyListeners();
  }

  Future<BiuxUser> getUser({required String id}) async {
    final user = await userFirebaseRepository.getUserById(id);
    notifyListeners();
    return user;
  }

  void changeLoading(bool loading) {
    this.loading = loading;
    notifyListeners();
  }

  Future<bool> createStory({
    required Story story,
    required List<AssetEntity> list,
  }) async {
    try {
      List<File> listFiles = [];
      
      for (var element in list) {
        final file = await element.file;
        if (file != null) {
          // ✅ REDIMENSIONAR IMAGEN: máximo 1350x1080
          final resizedFile = await _resizeImageFile(file);
          listFiles.add(resizedFile);
        }
      }
      
      if (listFiles.isEmpty) {
        print('Error: No hay archivos para subir');
        return false;
      }
      
      final result = await storiesFirebaseRepository.createStory(
        story: story,
        listFile: listFiles,
      );
      
      if (result) {
        // Limpiar las imágenes después de publicar
        imgList.clear();
        listTags.clear();
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      print('Error creando historia: $e');
      return false;
    }
  }

  /// Redimensiona una imagen a máximo 1350x1080
  /// Mantiene la relación de aspecto
  Future<File> _resizeImageFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        print('No se pudo decodificar la imagen');
        return imageFile;
      }
      
      // Máximas dimensiones permitidas
      const maxWidth = 1080;
      const maxHeight = 1350;
      
      // Si la imagen ya está dentro de los límites, retornarla sin cambios
      if (image.width <= maxWidth && image.height <= maxHeight) {
        print('Imagen dentro de límites (${image.width}x${image.height})');
        return imageFile;
      }
      
      // Calcular las nuevas dimensiones manteniendo relación de aspecto
      double widthRatio = maxWidth / image.width;
      double heightRatio = maxHeight / image.height;
      double ratio = widthRatio < heightRatio ? widthRatio : heightRatio;
      
      final newWidth = (image.width * ratio).toInt();
      final newHeight = (image.height * ratio).toInt();
      
      print('Redimensionando imagen: ${image.width}x${image.height} → ${newWidth}x${newHeight}');
      
      // Redimensionar imagen
      final resizedImage = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );
      
      // Guardar imagen redimensionada en un archivo temporal
      final resizedBytes = img.encodeJpg(resizedImage, quality: 85);
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/story_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(resizedBytes);
      
      print('Imagen redimensionada guardada: ${tempFile.path}');
      return tempFile;
    } catch (e) {
      print('Error redimensionando imagen: $e');
      // Si hay error, retornar archivo original
      return imageFile;
    }
  }

  Future<void> addLabel(String value) async {
    listTags.add(value);
    notifyListeners();
  }
}
