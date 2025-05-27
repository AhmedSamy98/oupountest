import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/endpoints.dart';
import 'offer_state.dart';
import '../data/models/offer_model.dart';

class OfferCubit extends Cubit<OfferState> {
  List<OfferModel> _offerList = [];
  
  OfferCubit() : super(OfferLoading());

  Future<void> load() async {
    emit(OfferLoading());
    try {
      final res = await DioClient.dio.get(Endpoints.offers);
      _offerList = (res.data as List).map((e) => OfferModel.fromJson(e)).toList();
      emit(OfferLoaded(_offerList));
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }

  Future<void> delete(String id) async {
    final currentState = state;
    if (currentState is OfferLoaded) {
      // Keep a copy of the current list in case we need to restore it
      final previousList = List<OfferModel>.from(_offerList);
      
      try {
        // Optimistically remove the item from the list immediately
        _offerList.removeWhere((offer) => offer.id == id);
        emit(OfferLoaded(_offerList));
        
        // Perform the actual delete operation
        final response = await DioClient.dio.delete('${Endpoints.offers}$id');
        
        // Check if the deletion was successful
        if (response.statusCode == 200 || response.statusCode == 204) {
          emit(OfferDeleted(id, OfferLoaded(_offerList)));
        } else {
          // Restore the previous list if the delete failed
          _offerList = previousList;
          emit(OfferLoaded(_offerList));
          throw Exception('فشل حذف العرض، الرجاء المحاولة مرة أخرى');
        }
      } catch (e) {
        // Restore the previous list on error
        _offerList = previousList;
        emit(OfferLoaded(_offerList));
        throw e;
      }
    }
  }  // Upload images for an offer

  Future<void> uploadImages(String offerId, List<File> images) async {
    final currentState = state;
    if (currentState is OfferLoaded) {
      try {
        // Prepare the form data
        FormData formData = FormData();
        
        // Add each image file to the form data
        for (var i = 0; i < images.length; i++) {
          File file = images[i];
          String fileName = file.path.split('/').last;
          
          formData.files.add(
            MapEntry(
              'files',
              await MultipartFile.fromFile(
                file.path,
                filename: fileName,
              ),
            ),
          );
          
          // Update progress - 0% at the beginning
          emit(OfferImageUploading(offerId, 0.0));
        }
        
        // Create onSendProgress callback to track upload progress
        void onSendProgress(int sent, int total) {
          double progress = sent / total;
          emit(OfferImageUploading(offerId, progress));
        }
        
        // Make the API request to upload images
        final response = await DioClient.dio.post(
          Endpoints.offerImagesUpload(offerId),
          data: formData,
          onSendProgress: onSendProgress,
        );
        
        // Handle the response
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Extract the image IDs from the response
          List<String> imageIds = [];
          print("Response data: ${response.data}"); // للتشخيص

          if (response.data is List) {
            imageIds = (response.data as List).map((id) => id.toString()).toList();
          } else if (response.data is Map) {
            // تحقق من مفاتيح متعددة محتملة في الاستجابة
            if (response.data.containsKey('image_ids')) {
              var ids = response.data['image_ids'];
              if (ids is List) {
                imageIds = ids.map((id) => id.toString()).toList();
              }
            } else if (response.data.containsKey('imageIds')) {
              var ids = response.data['imageIds'];
              if (ids is List) {
                imageIds = ids.map((id) => id.toString()).toList();
              }
            } else if (response.data.containsKey('images')) {
              var ids = response.data['images'];
              if (ids is List) {
                imageIds = ids.map((id) => id.toString()).toList();
              }
            }
          }

          print("Extracted image IDs: $imageIds"); // للتشخيص

          // Update the offer in the list with the new image IDs
          if (imageIds.isNotEmpty) {
            _updateOfferWithImages(offerId, imageIds);
          }

          // Emit the success state
          emit(OfferImageUploaded(offerId, imageIds, OfferLoaded(_offerList)));
        } else {
          throw Exception('فشل رفع الصور، الرجاء المحاولة مرة أخرى');
        }
      } catch (e) {
        emit(OfferImageError(offerId, e.toString(), currentState));
        throw e;
      }
    }
  }

  // Upload web images for an offer (used in web environments)
  Future<void> uploadWebImages(String offerId, List<PlatformFile> files) async {
    final currentState = state;
    if (currentState is OfferLoaded) {
      try {
        // Prepare the form data
        FormData formData = FormData();
        
        // Add each image file to the form data
        for (var i = 0; i < files.length; i++) {
          PlatformFile file = files[i];
          
          if (file.bytes != null) {
            formData.files.add(
              MapEntry(
                'files',
                MultipartFile.fromBytes(
                  file.bytes!,
                  filename: file.name,
                ),
              ),
            );
          }
          
          // Update progress - 0% at the beginning
          emit(OfferImageUploading(offerId, 0.0));
        }
        
        // Create onSendProgress callback to track upload progress
        void onSendProgress(int sent, int total) {
          double progress = sent / total;
          emit(OfferImageUploading(offerId, progress));
        }
        
        // Make the API request to upload images
        final response = await DioClient.dio.post(
          Endpoints.offerImagesUpload(offerId),
          data: formData,
          onSendProgress: onSendProgress,
        );
        
        // Handle the response
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Extract the image IDs from the response
          List<String> imageIds = [];
          if (response.data is List) {
            imageIds = (response.data as List).map((id) => id.toString()).toList();
          } else if (response.data is Map && response.data.containsKey('imageIds')) {
            imageIds = List<String>.from(response.data['imageIds']);
          }
          
          // Update the offer in the list with the new image IDs
          _updateOfferWithImages(offerId, imageIds);
          
          // Emit the success state
          emit(OfferImageUploaded(offerId, imageIds, OfferLoaded(_offerList)));
        } else {
          throw Exception('فشل رفع الصور، الرجاء المحاولة مرة أخرى');
        }
      } catch (e) {
        emit(OfferImageError(offerId, e.toString(), currentState));
        throw e;
      }
    }
  }

  // Get images for an offer
  Future<List<String>> getOfferImageUrls(String offerId) async {
    try {
      final response = await DioClient.dio.get(Endpoints.offerImages(offerId));
      
      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List).map((url) => url.toString()).toList();
        } else if (response.data is Map && response.data.containsKey('urls')) {
          return List<String>.from(response.data['urls']);
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // Delete an image from an offer
  Future<void> deleteImage(String offerId, String imageId) async {
    final currentState = state;
    if (currentState is OfferLoaded) {
      try {
        // Make the API request to delete the image
        final response = await DioClient.dio.delete(Endpoints.offerImageById(offerId, imageId));
        
        // Handle the response
        if (response.statusCode == 200 || response.statusCode == 204) {
          // Update the offer in the list by removing the deleted image ID
          _updateOfferByRemovingImage(offerId, imageId);
          
          // Emit the updated state
          emit(OfferLoaded(_offerList));
        } else {
          throw Exception('فشل حذف الصورة، الرجاء المحاولة مرة أخرى');
        }
      } catch (e) {
        throw e;
      }
    }
  }

  // Helper method to update an offer with new image IDs
  void _updateOfferWithImages(String offerId, List<String> newImageIds) {
    _offerList = _offerList.map((offer) {
      if (offer.id == offerId) {
        // Create a new instance of the offer with the updated images list
        return OfferModel(
          id: offer.id,
          createdAt: offer.createdAt,
          updatedAt: offer.updatedAt,
          businessId: offer.businessId,
          categoryId: offer.categoryId,
          cityIds: offer.cityIds,
          branchIds: offer.branchIds,
          title: offer.title,
          description: offer.description,
          images: [...offer.images, ...newImageIds],
          options: offer.options,
          highlights: offer.highlights,
          termsAndConditions: offer.termsAndConditions,
          aboutOffer: offer.aboutOffer,
          requireBooking: offer.requireBooking,
          phoneNumber: offer.phoneNumber,
          isActive: offer.isActive,
          optionDescription: offer.optionDescription,
          cancellationPolicy: offer.cancellationPolicy,
          startDate: offer.startDate,
          endDate: offer.endDate,
          validUntil: offer.validUntil,
          validUnit: offer.validUnit,
          offerLabel: offer.offerLabel,
          maxNoOrders: offer.maxNoOrders,
        );
      }
      return offer;
    }).toList();
  }

  // Helper method to update an offer by removing an image ID
  void _updateOfferByRemovingImage(String offerId, String imageId) {
    _offerList = _offerList.map((offer) {
      if (offer.id == offerId) {
        // Create a new instance of the offer with the updated images list
        return OfferModel(
          id: offer.id,
          createdAt: offer.createdAt,
          updatedAt: offer.updatedAt,
          businessId: offer.businessId,
          categoryId: offer.categoryId,
          cityIds: offer.cityIds,
          branchIds: offer.branchIds,
          title: offer.title,
          description: offer.description,
          images: offer.images.where((id) => id != imageId).toList(),
          options: offer.options,
          highlights: offer.highlights,
          termsAndConditions: offer.termsAndConditions,
          aboutOffer: offer.aboutOffer,
          requireBooking: offer.requireBooking,
          phoneNumber: offer.phoneNumber,
          isActive: offer.isActive,
          optionDescription: offer.optionDescription,
          cancellationPolicy: offer.cancellationPolicy,
          startDate: offer.startDate,
          endDate: offer.endDate,
          validUntil: offer.validUntil,
          validUnit: offer.validUnit,
          offerLabel: offer.offerLabel,
          maxNoOrders: offer.maxNoOrders,
        );
      }
      return offer;
    }).toList();
  }
}
