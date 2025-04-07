import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:lostandfound/model/chategory_model.dart';
import 'package:lostandfound/view/add_items/add_items_provider/add_items_provider.dart';
import 'package:lostandfound/view/add_items/widgets/map.dart';
import 'package:lostandfound/view/home_screen/home_screen_provider/home_screen_provider.dart';
import 'package:provider/provider.dart';

class ItemFormFields extends StatelessWidget {
  final TextEditingController itemNameController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController geotagController;
  final String type;
  final Category? selectedCategory;
  final Function(String) onTypeChanged;
  final Function(Category?) onCategoryChanged;
  final VoidCallback onMapPicker;
  final VoidCallback onGenerateAIDescription;
  final Color primaryColor;
  final Color accentColor;

  const ItemFormFields({
    super.key,
    required this.itemNameController,
    required this.descriptionController,
    required this.locationController,
    required this.geotagController,
    required this.type,
    required this.selectedCategory,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onMapPicker,
    required this.onGenerateAIDescription,
    required this.primaryColor,
    required this.accentColor,
  });

  InputDecoration _buildInputDecoration(String label, String hint,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
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
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Type:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => onTypeChanged('lost'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: type == 'lost'
                                ? primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search,
                                  color: type == 'lost'
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text('Lost',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: type == 'lost'
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
                        onTap: () => onTypeChanged('found'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: type == 'found'
                                ? primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: type == 'found'
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text('Found',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: type == 'found'
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
        const SizedBox(height: 20),
        TextFormField(
          controller: itemNameController,
          decoration: _buildInputDecoration('Item Name', 'e.g., Blue Backpack',
              suffixIcon: Icon(Icons.inventory_2, color: accentColor)),
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter an item name'
              : null,
        ),
        const SizedBox(height: 16),
        Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            return DropdownButtonFormField<Category>(
              value: selectedCategory,
              hint: const Text('Select Category'),
              decoration: _buildInputDecoration('Category', 'Select a category',
                  suffixIcon: Icon(Icons.category, color: accentColor)),
              items: categoryProvider.categories.map((Category category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.categoryName),
                );
              }).toList(),
              onChanged: onCategoryChanged,
              validator: (value) =>
                  value == null ? 'Please select a category' : null,
              dropdownColor: Colors.white,
              icon: Icon(Icons.arrow_drop_down, color: primaryColor),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: descriptionController,
                decoration: _buildInputDecoration('Description',
                    'e.g., Blue leather wallet with white stitching',
                    suffixIcon: Icon(Icons.description, color: accentColor)),
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
                  color: primaryColor, borderRadius: BorderRadius.circular(12)),
              child: IconButton(
                icon: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 24),
                onPressed: onGenerateAIDescription,
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
                controller: locationController,
                decoration: _buildInputDecoration(
                    'Location', 'e.g., Central Park',
                    suffixIcon: Icon(Icons.location_on, color: accentColor)),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                  color: primaryColor, borderRadius: BorderRadius.circular(12)),
              child: IconButton(
                icon: const Icon(Icons.map, color: Colors.white, size: 24),
                onPressed: onMapPicker,
                tooltip: 'Select on map',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: geotagController,
          decoration: _buildInputDecoration(
              'Coordinates', 'Latitude, Longitude',
              suffixIcon: Icon(Icons.my_location, color: accentColor)),
          enabled: false,
        ),
      ],
    );
  }
}
