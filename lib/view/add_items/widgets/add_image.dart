// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lostandfound/model/item_model.dart';
import 'package:lostandfound/view/add_items/add_items_provider/add_items_provider.dart';
import 'package:provider/provider.dart';

class ItemImageSection extends StatelessWidget {
  final File? imageFile;
  final Item item;
  final VoidCallback onPickImage;
  final VoidCallback onTakePicture;
  final VoidCallback onClearImage;
  final Color primaryColor;
  final Color accentColor;

  // ignore: use_key_in_widget_constructors
  const ItemImageSection({
    required this.imageFile,
    required this.item,
    required this.onPickImage,
    required this.onTakePicture,
    required this.onClearImage,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Item Image',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16)),
          const SizedBox(height: 12),
          Center(
            child: imageFile != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            Image.file(imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7), shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 18),
                            onPressed: onClearImage,
                            constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  )
                : item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              '${Provider.of<ItemProvider>(context, listen: false).baseUrl}/static/uploads/${item.imageUrl}',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image, size: 48, color: Colors.grey.shade500),
                                    const SizedBox(height: 8),
                                    Text('Image unavailable',
                                        style: TextStyle(color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7), shape: BoxShape.circle),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                onPressed: onClearImage,
                                constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 48, color: Colors.grey.shade500),
                            const SizedBox(height: 8),
                            Text('No image selected',
                                style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPickImage,
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onTakePicture,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}