import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'cloudinary_service.dart';

/// Storage Service - Now using Cloudinary instead of Firebase Storage
/// 
/// This service provides image upload/download functionality using Cloudinary.
/// Cloudinary offers 25 GB storage and 25 GB bandwidth per month for FREE.
/// 
/// Setup Instructions:
/// 1. Sign up at https://cloudinary.com/
/// 2. Get your Cloud Name and Upload Preset from the dashboard
/// 3. Update credentials in .env file
class StorageService {
  final CloudinaryService _cloudinary = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    return await _picker.pickImage(source: ImageSource.gallery);
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    return await _picker.pickImage(source: ImageSource.camera);
  }

  // Upload profile picture
  Future<String?> uploadProfilePicture(File file, String userId) async {
    return await _cloudinary.uploadImage(file, folder: 'sahara/profiles/$userId');
  }

  // Upload pet picture
  Future<String?> uploadPetPicture(File file, String petId) async {
    return await _cloudinary.uploadImage(file, folder: 'sahara/pets/$petId');
  }

  // Upload chat image
  Future<String?> uploadChatImage(File file) async {
    return await _cloudinary.uploadImage(file, folder: 'sahara/chats');
  }

  // Delete image
  Future<bool> deleteImage(String imageUrl) async {
    final publicId = _cloudinary.getPublicIdFromUrl(imageUrl);
    if (publicId != null) {
      return await _cloudinary.deleteImage(publicId);
    }
    return false;
  }
}
