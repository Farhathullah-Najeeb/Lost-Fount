// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:image_picker/image_picker.dart';
import 'package:lostandfound/model/chategory_model.dart';
import 'package:lostandfound/model/item_model.dart';
import 'package:lostandfound/view/add_items/add_items_provider/add_items_provider.dart';
import 'package:lostandfound/view/add_items/widgets/map.dart';
import 'package:lostandfound/view/home_screen/home_screen_provider/home_screen_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
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

  // Colors (matching CreateItemDialog)
  final Color _primaryColor = Colors.blue.shade700;
  final Color _accentColor = Colors.blue.shade400;
  final Color _backgroundColor = Colors.white;
  final Color _errorColor = Colors.red.shade400;

  // Gemini AI Setup
  static const String _apiKey =
      'AIzaSyDz5maMJd0BcmG3ndH9asrZSOJ2bFh2ayg'; // Your Gemini API key
  late GenerativeModel _geminiModel;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _initializeFields();
    _geminiModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
      print('User ID loaded: $_userId');
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
    // Load category
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
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          print('Image picked: ${pickedFile.path}');
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          print('Picture taken: ${pickedFile.path}');
        });
      }
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

    print('Opening MapPickerDialog with initial position: $initialPosition');

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
          print('Selected location: $result, Address: $locationName');
        });
      } catch (e) {
        _showErrorSnackBar('Failed to get address: $e');
        setState(() {
          _selectedLocation = result;
          _geotagController.text = '${result.latitude},${result.longitude}';
          _locationController.text =
              'Location selected (${result.latitude}, ${result.longitude})';
          print('Selected location: $result (address lookup failed)');
        });
      }
    } else {
      print('No location selected from map');
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

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Current position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      _showErrorSnackBar('Failed to get location: $e');
      return null;
    }
  }

  Future<void> _updateItem(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
      print('Item updated successfully');
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
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'AI-Generated Descriptions',
            style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: suggestions.map((description) {
                return ListTile(
                  title: Text(description),
                  onTap: () => Navigator.pop(context, description),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  tileColor: Colors.grey.shade50,
                  hoverColor: _accentColor.withOpacity(0.1),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: _primaryColor)),
            ),
          ],
        ),
      );

      if (selectedDescription != null) {
        setState(() {
          _descriptionController.text = selectedDescription;
          print('AI description selected: $selectedDescription');
        });
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

  InputDecoration _buildInputDecoration(String label, String hint,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: _primaryColor, fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _errorColor, width: 1),
      ),
      suffixIcon: suffixIcon,
    );
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
                          color: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text('Type:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _type = 'lost'),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _type == 'lost'
                                            ? _primaryColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.search,
                                              color: _type == 'lost'
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                              size: 20),
                                          const SizedBox(width: 8),
                                          Text('Lost',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _type == 'lost'
                                                      ? Colors.white
                                                      : Colors.grey.shade600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: () =>
                                        setState(() => _type = 'found'),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _type == 'found'
                                            ? _primaryColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle_outline,
                                              color: _type == 'found'
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                              size: 20),
                                          const SizedBox(width: 8),
                                          Text('Found',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _type == 'found'
                                                      ? Colors.white
                                                      : Colors.grey.shade600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _itemNameController,
                    decoration: _buildInputDecoration(
                        'Item Name', 'e.g., Blue Backpack',
                        suffixIcon:
                            Icon(Icons.inventory_2, color: _accentColor)),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter an item name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      return DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        hint: const Text('Select Category'),
                        decoration: _buildInputDecoration(
                            'Category', 'Select a category',
                            suffixIcon:
                                Icon(Icons.category, color: _accentColor)),
                        items: categoryProvider.categories
                            .map((Category category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.categoryName),
                          );
                        }).toList(),
                        onChanged: (Category? value) =>
                            setState(() => _selectedCategory = value),
                        validator: (value) =>
                            value == null ? 'Please select a category' : null,
                        dropdownColor: _backgroundColor,
                        icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _descriptionController,
                          decoration: _buildInputDecoration('Description',
                              'e.g., Blue leather wallet with white stitching',
                              suffixIcon:
                                  Icon(Icons.description, color: _accentColor)),
                          maxLines: 3,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter a description'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                            color: _primaryColor,
                            borderRadius: BorderRadius.circular(12)),
                        child: IconButton(
                          icon: const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 24),
                          onPressed: () => _generateAIDescription(context),
                          tooltip: 'Generate AI Description',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _locationController,
                          decoration: _buildInputDecoration(
                              'Location', 'e.g., Central Park',
                              suffixIcon:
                                  Icon(Icons.location_on, color: _accentColor)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                            color: _primaryColor,
                            borderRadius: BorderRadius.circular(12)),
                        child: IconButton(
                          icon: const Icon(Icons.map,
                              color: Colors.white, size: 24),
                          onPressed: () => _showMapPicker(context),
                          tooltip: 'Select on map',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _geotagController,
                    decoration: _buildInputDecoration(
                        'Coordinates', 'Latitude, Longitude',
                        suffixIcon:
                            Icon(Icons.my_location, color: _accentColor)),
                    enabled: false,
                  ),
                  const SizedBox(height: 24),
                  Container(
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
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                                fontSize: 16)),
                        const SizedBox(height: 12),
                        Center(
                          child: _imageFile != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(_imageFile!,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.7),
                                            shape: BoxShape.circle),
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.white, size: 18),
                                          onPressed: () =>
                                              setState(() => _imageFile = null),
                                          constraints: const BoxConstraints(
                                              minHeight: 30, minWidth: 30),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : widget.item.imageUrl != null &&
                                      widget.item.imageUrl!.isNotEmpty
                                  ? Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            '${Provider.of<ItemProvider>(context, listen: false).baseUrl}/static/uploads/${widget.item.imageUrl}',
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              height: 150,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade200),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.image,
                                                      size: 48,
                                                      color:
                                                          Colors.grey.shade500),
                                                  const SizedBox(height: 8),
                                                  Text('Image unavailable',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade600)),
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
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                shape: BoxShape.circle),
                                            child: IconButton(
                                              icon: const Icon(Icons.close,
                                                  color: Colors.white,
                                                  size: 18),
                                              onPressed: () => setState(
                                                  () => _imageFile = null),
                                              constraints: const BoxConstraints(
                                                  minHeight: 30, minWidth: 30),
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
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.image,
                                              size: 48,
                                              color: Colors.grey.shade500),
                                          const SizedBox(height: 8),
                                          Text('No image selected',
                                              style: TextStyle(
                                                  color: Colors.grey.shade600)),
                                        ],
                                      ),
                                    ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.photo_library, size: 18),
                                label: const Text('Gallery'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accentColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _takePicture,
                                icon: const Icon(Icons.camera_alt, size: 18),
                                label: const Text('Camera'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accentColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _primaryColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Consumer<ItemProvider>(
                          builder: (context, itemProvider, child) {
                            return ElevatedButton(
                              onPressed: itemProvider.isLoading
                                  ? null
                                  : () => _updateItem(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                elevation: 2,
                              ),
                              child: itemProvider.isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Update',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                            );
                          },
                        ),
                      ),
                    ],
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
