// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, curly_braces_in_flow_control_structures, use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:image_picker/image_picker.dart';
import 'package:lostandfound/model/chategory_model.dart';
import 'package:lostandfound/model/item_model.dart';
import 'package:lostandfound/view/add_items/add_items_provider/add_items_provider.dart';
import 'package:lostandfound/view/add_items/widgets/add_image.dart';
import 'package:lostandfound/view/add_items/widgets/add_texformfield.dart';
import 'package:lostandfound/view/add_items/widgets/ai_discription.dart';
import 'package:lostandfound/view/add_items/widgets/item_action_button.dart';
import 'package:lostandfound/view/add_items/widgets/map.dart';
import 'package:lostandfound/view/home_screen/home_screen_provider/home_screen_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class EditItemDialog extends StatefulWidget {
  final Item item;

  const EditItemDialog({required this.item, super.key});

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _geotagController = TextEditingController();
  File? _imageFile;
  final picker = ImagePicker();
  String _type = 'lost';
  Category? _selectedCategory;
  latlng.LatLng? _selectedLocation;
  int? _userId;
  final _formKey = GlobalKey<FormState>();

  final Color _primaryColor = Colors.blue.shade700;
  final Color _accentColor = Colors.blue.shade400;
  final Color _backgroundColor = Colors.white;
  final Color _errorColor = Colors.red.shade400;

  static const String _apiKey = 'AIzaSyDz5maMJd0BcmG3ndH9asrZSOJ2bFh2ayg';
  late GenerativeModel _geminiModel;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _initializeFields();
    _geminiModel = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
    });
  }

  void _initializeFields() {
    _itemNameController.text = widget.item.itemName;
    _descriptionController.text = widget.item.description ?? '';
    _locationController.text = widget.item.location ?? '';
    _geotagController.text = widget.item.geotag ?? '';
    _type = widget.item.type ?? 'lost';
    if (widget.item.geotag != null && widget.item.geotag!.isNotEmpty) {
      try {
        final coords = widget.item.geotag!.split(',');
        _selectedLocation =
            latlng.LatLng(double.parse(coords[0]), double.parse(coords[1]));
      } catch (e) {
        print('Error parsing geotag: $e');
      }
    }
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.fetchCategories().then((_) {
      setState(() {
        _selectedCategory = categoryProvider.categories.firstWhere(
          (cat) => cat.id == widget.item.categoryId,
          orElse: () => categoryProvider.categories.first,
        );
      });
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null)
        setState(() => _imageFile = File(pickedFile.path));
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (pickedFile != null)
        setState(() => _imageFile = File(pickedFile.path));
    } catch (e) {
      _showErrorSnackBar('Failed to take picture: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Future<void> _showMapPicker(BuildContext context) async {
    Position? position = await _determinePosition();
    latlng.LatLng initialPosition = position != null
        ? latlng.LatLng(position.latitude, position.longitude)
        : _selectedLocation ?? const latlng.LatLng(37.7749, -122.4194);

    latlng.LatLng? result = await showDialog(
      context: context,
      builder: (context) => MapPickerDialog(initialPosition: initialPosition),
    );

    if (result != null) {
      try {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(result.latitude, result.longitude);
        Placemark placemark = placemarks.first;
        String locationName = [
          placemark.street,
          placemark.locality,
          placemark.administrativeArea,
          placemark.country
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        setState(() {
          _selectedLocation = result;
          _geotagController.text = '${result.latitude},${result.longitude}';
          _locationController.text = locationName.isNotEmpty
              ? locationName
              : 'Location selected (${result.latitude}, ${result.longitude})';
        });
      } catch (e) {
        _showErrorSnackBar('Failed to get address: $e');
        setState(() {
          _selectedLocation = result;
          _geotagController.text = '${result.latitude},${result.longitude}';
          _locationController.text =
              'Location selected (${result.latitude}, ${result.longitude})';
        });
      }
    }
  }

  Future<Position?> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar('Please enable location services');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar('Location permissions are permanently denied');
        return null;
      }

      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      _showErrorSnackBar('Failed to get location: $e');
      return null;
    }
  }

  Future<void> _updateItem(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_userId == null) {
      _showErrorSnackBar('User ID not found. Please log in again.');
      return;
    }

    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    bool success = await itemProvider.updateItem(
      id: widget.item.id,
      userId: _userId!,
      itemName: _itemNameController.text,
      categoryId: _selectedCategory!.id,
      type: _type,
      description: _descriptionController.text,
      location: _locationController.text,
      geotag: _geotagController.text,
      image: _imageFile,
    );

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item updated successfully'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
        ),
      );
    } else {
      _showErrorSnackBar(itemProvider.error ?? 'Failed to update item');
    }
  }

  Future<void> _generateAIDescription(BuildContext context) async {
    if (_itemNameController.text.isEmpty) {
      _showErrorSnackBar('Please enter an item name first');
      return;
    }

    final itemName = _itemNameController.text.trim();
    final isLost = _type == 'lost';
    final currentTime = DateTime.now();
    final timeString = "${currentTime.hour}:${currentTime.minute}";
    final dateString =
        "${currentTime.day}/${currentTime.month}/${currentTime.year}";

    final prompt = '''
    Generate 3 detailed descriptions for a ${isLost ? 'lost' : 'found'} item named "$itemName". 
    Include the date ($dateString) and time ($timeString) of the event, and describe at least 2 specific conditions or features of the item (e.g., its physical state, unique marks, etc.). 
    Return each description as a separate paragraph. Do not use special characters or emojis.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _geminiModel.generateContent(content);
      final generatedText = response.text ?? '';

      final suggestions = generatedText
          .split('\n\n')
          .where((desc) => desc.trim().isNotEmpty)
          .toList();

      if (suggestions.isEmpty) {
        _showErrorSnackBar('No descriptions generated by AI');
        return;
      }

      String? selectedDescription = await showDialog<String>(
        context: context,
        builder: (context) => AIDescriptionDialog(
          suggestions: suggestions,
          primaryColor: _primaryColor,
          accentColor: _accentColor,
        ),
      );

      if (selectedDescription != null) {
        setState(() => _descriptionController.text = selectedDescription);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to generate descriptions: $e');
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _geotagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit, color: _primaryColor, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Edit Item',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 16),
                  ItemFormFields(
                    itemNameController: _itemNameController,
                    descriptionController: _descriptionController,
                    locationController: _locationController,
                    geotagController: _geotagController,
                    type: _type,
                    selectedCategory: _selectedCategory,
                    onTypeChanged: (value) => setState(() => _type = value),
                    onCategoryChanged: (value) =>
                        setState(() => _selectedCategory = value),
                    onMapPicker: () => _showMapPicker(context),
                    onGenerateAIDescription: () =>
                        _generateAIDescription(context),
                    primaryColor: _primaryColor,
                    accentColor: _accentColor,
                  ),
                  const SizedBox(height: 24),
                  ItemImageSection(
                    imageFile: _imageFile,
                    item: widget.item,
                    onPickImage: _pickImage,
                    onTakePicture: _takePicture,
                    onClearImage: () => setState(() => _imageFile = null),
                    primaryColor: _primaryColor,
                    accentColor: _accentColor,
                  ),
                  const SizedBox(height: 24),
                  Consumer<ItemProvider>(
                    builder: (context, itemProvider, child) {
                      return ItemActionButtons(
                        isLoading: itemProvider.isLoading,
                        onCancel: () => Navigator.of(context).pop(),
                        onUpdate: () => _updateItem(context),
                        primaryColor: _primaryColor,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
