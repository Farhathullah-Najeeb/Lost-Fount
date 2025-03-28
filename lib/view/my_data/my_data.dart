// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lostandfound/model/item_model.dart';
import 'package:lostandfound/view/add_items/widgets/edit_item_dialougue.dart';
import 'package:lostandfound/view/delete_item/delete_item_provider.dart';
import 'package:lostandfound/view/my_data/user_data_provider/user_data_provider.dart';
import 'package:lostandfound/view/police_view/police_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyItemsScreenState createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> {
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    Future.microtask(() =>
        Provider.of<UserItemsProvider>(context, listen: false)
            .getItemsByUserId());
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
    });
  }

  Future<void> _deleteItem(BuildContext context, Item item) async {
    if (_userId == null || _userId != item.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('You can only delete your own items')),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
        ),
      );
      return;
    }

    final deleteProvider =
        Provider.of<DeleteItemProvider>(context, listen: false);
    final userItemsProvider =
        Provider.of<UserItemsProvider>(context, listen: false);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Delete Item',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Text(
            'Are you sure you want to delete "${item.itemName}"? This action cannot be undone.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Consumer<DeleteItemProvider>(
            builder: (context, deleteProvider, child) {
              return ElevatedButton(
                onPressed: deleteProvider.isLoading
                    ? null
                    : () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: deleteProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Delete',
                        style: TextStyle(fontWeight: FontWeight.w500)),
              );
            },
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bool success = await deleteProvider.deleteItem(item.id);
      if (success) {
        await userItemsProvider.getItemsByUserId(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Item deleted successfully')),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(deleteProvider.errorMessage ??
                        'Failed to delete item')),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    }
  }

  Future<void> _editItem(BuildContext context, Item item) async {
    if (_userId == null || _userId != item.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('You can only edit your own items')),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => EditItemDialog(item: item),
    ).then((_) {
      Provider.of<UserItemsProvider>(context, listen: false)
          .getItemsByUserId(); // Refresh the list after editing
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      body: Consumer<UserItemsProvider>(
        builder: (context, userItemsProvider, child) {
          if (userItemsProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading your items...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          } else if (userItemsProvider.error != null) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.error_outline,
                            color: Colors.red, size: 60),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Oops! Something went wrong.',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userItemsProvider.error ?? 'Unknown error',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => userItemsProvider.getItemsByUserId(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (userItemsProvider.items.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.search,
                            color: Colors.blue.shade300, size: 60),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No items yet',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade50, Colors.white],
                  stops: const [0.0, 0.2],
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                itemCount: userItemsProvider.items.length,
                itemBuilder: (context, index) {
                  Item item = userItemsProvider.items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/item-details',
                                arguments: item.id);
                          },
                          splashColor: Colors.blue.withOpacity(0.1),
                          highlightColor: Colors.blue.withOpacity(0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Item type badge
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: item.type == 'lost'
                                      ? Colors.red.shade50
                                      : Colors.green.shade50,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      item.type == 'lost'
                                          ? Icons.search
                                          : Icons.check_circle_outline,
                                      color: item.type == 'lost'
                                          ? Colors.red.shade400
                                          : Colors.green.shade400,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.type == 'lost'
                                          ? 'LOST ITEM'
                                          : 'FOUND ITEM',
                                      style: TextStyle(
                                        color: item.type == 'lost'
                                            ? Colors.red.shade700
                                            : Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  // Adjust image size based on screen width
                                  final imageSize =
                                      isSmallScreen ? 80.0 : 100.0;

                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Item image with nice rounded corners
                                      Hero(
                                        tag: 'item-image-${item.id}',
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: item.imageUrl != null
                                              ? Image.network(
                                                  '${userItemsProvider.baseUrl}/static/uploads/${item.imageUrl}',
                                                  width: imageSize,
                                                  height: imageSize,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      // ignore: curly_braces_in_flow_control_structures
                                                      return child;
                                                    return Container(
                                                      width: imageSize,
                                                      height: imageSize,
                                                      color: Colors.grey[200],
                                                      child: const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      width: imageSize,
                                                      height: imageSize,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Icon(
                                                          Icons.broken_image,
                                                          color:
                                                              Colors.grey[400],
                                                          size: 36),
                                                    );
                                                  },
                                                )
                                              : Container(
                                                  width: imageSize,
                                                  height: imageSize,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Icon(Icons.image,
                                                      color: Colors.grey[400],
                                                      size: 36),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Item details with better spacing and overflow handling
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.itemName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on_outlined,
                                                    color: Colors.blue.shade400,
                                                    size: 16),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    item.location ??
                                                        'No location specified',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[700],
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today,
                                                    color: Colors.blue.shade400,
                                                    size: 16),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Posted: ${item.dateTime}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                              // Action buttons in a nice row with responsive layout
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: isSmallScreen
                                    // For small screens, use a column layout
                                    ? Column(
                                        children: [
                                          _buildActionButton(
                                            icon: Icons.visibility_outlined,
                                            text: 'View',
                                            color: Colors.blue.shade600,
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, '/item-details',
                                                  arguments: item.id);
                                            },
                                          ),
                                          Divider(
                                              height: 1,
                                              thickness: 1,
                                              color: Colors.grey[300]),
                                          _buildActionButton(
                                            icon: Icons.edit_outlined,
                                            text: 'Edit',
                                            color: Colors.amber.shade600,
                                            onTap: () =>
                                                _editItem(context, item),
                                          ),
                                          Divider(
                                              height: 1,
                                              thickness: 1,
                                              color: Colors.grey[300]),
                                          _buildActionButton(
                                            icon: Icons.delete_outlined,
                                            text: 'Delete',
                                            color: Colors.red.shade600,
                                            onTap: () =>
                                                _deleteItem(context, item),
                                          ),
                                        ],
                                      )
                                    // For normal screens, use a row layout
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: _buildActionButton(
                                              icon: Icons.visibility_outlined,
                                              text: 'View',
                                              color: Colors.blue.shade600,
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, '/item-details',
                                                    arguments: item.id);
                                              },
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 24,
                                            color: Colors.grey[300],
                                          ),
                                          Expanded(
                                            child: _buildActionButton(
                                              icon: Icons.edit_outlined,
                                              text: 'Edit',
                                              color: Colors.amber.shade600,
                                              onTap: () =>
                                                  _editItem(context, item),
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 24,
                                            color: Colors.grey[300],
                                          ),
                                          Expanded(
                                            child: _buildActionButton(
                                              icon: Icons.delete_outlined,
                                              text: 'Delete',
                                              color: Colors.red.shade600,
                                              onTap: () =>
                                                  _deleteItem(context, item),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  // Helper method to build consistent action buttons
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
