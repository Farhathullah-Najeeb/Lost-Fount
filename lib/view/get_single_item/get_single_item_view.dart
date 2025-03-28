// ignore_for_file: library_private_types_in_public_api, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:lostandfound/model/item_model.dart';
import 'package:lostandfound/view/get_single_item/get_single_item_provider/get_single_item_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailsScreen extends StatefulWidget {
  final int itemId;

  const ItemDetailsScreen({required this.itemId, super.key});

  @override
  _ItemDetailsScreenState createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  latlng.LatLng? _itemLocation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SingleItemProvider>(context, listen: false)
            .getSingleItem(widget.itemId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return DateFormat('MMMM d, yyyy • h:mm a').format(date);
    } catch (e) {
      return dateTime;
    }
  }

  Future<void> _launchMap(String geotag) async {
    if (geotag.isEmpty || _itemLocation == null) return;

    // Show a dialog with full-screen FlutterMap instead of launching Google Maps
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => FullScreenMapDialog(location: _itemLocation!),
    );

    // Fallback to external Google Maps if user chooses to
    if (result == true) {
      try {
        final Uri mapUrl = Uri.parse('https://maps.google.com/maps?q=$geotag');
        if (await canLaunchUrl(mapUrl)) {
          await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $mapUrl';
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open map: $e')),
        );
      }
    }
  }

  latlng.LatLng? _parseGeotag(String? geotag) {
    if (geotag == null || geotag.isEmpty) return null;
    try {
      final parts = geotag.split(',');
      if (parts.length != 2) return null;
      final latitude = double.parse(parts[0].trim());
      final longitude = double.parse(parts[1].trim());
      return latlng.LatLng(latitude, longitude);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SingleItemProvider>(
      builder: (context, singleItemProvider, child) {
        if (singleItemProvider.isLoading) {
          return _buildLoadingState();
        } else if (singleItemProvider.error != null) {
          return _buildErrorState(singleItemProvider);
        } else if (singleItemProvider.item == null) {
          return _buildNotFoundState();
        } else {
          Item item = singleItemProvider.item!;
          final bool isLost = item.type.toLowerCase() == 'lost';
          final Color statusColor = isLost ? Colors.deepOrange : Colors.teal;
          _itemLocation = _parseGeotag(item.geotag);

          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 0,
                    floating: true,
                    pinned: true,
                    backgroundColor: statusColor,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: Text(
                      item.type.capitalize(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageHeader(
                        item, isLost, statusColor, singleItemProvider),
                    _buildItemTitle(item, statusColor),
                    _buildItemDetails(item, statusColor),
                    if (_itemLocation != null) _buildMapSection(),
                    _buildBottomSection(isLost, statusColor),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact functionality coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              backgroundColor: statusColor,
              icon: const Icon(Icons.chat_bubble_outline),
              label: Text(isLost ? 'I Found It!' : 'This Is Mine!'),
              elevation: 4,
            ),
          );
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[400]!),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading item details...',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(SingleItemProvider provider) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.error_outline, color: Colors.red[700], size: 70),
              ),
              const SizedBox(height: 32),
              Text(
                'Unable to Load Item',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                provider.error ?? 'An unexpected error occurred',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.getSingleItem(widget.itemId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFE0E0E0),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Item Not Found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We couldn\'t find the item you\'re looking for. It may have been removed or deleted.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Return To Browse'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader(
      Item item, bool isLost, Color statusColor, SingleItemProvider provider) {
    return Stack(
      children: [
        if (item.imageUrl != null)
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Image.network(
              '${provider.baseUrl}/static/uploads/${item.imageUrl}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: statusColor.withOpacity(0.1),
                  child: Center(
                    child: Icon(
                      isLost ? Icons.search : Icons.inventory_2,
                      size: 80,
                      color: statusColor.withOpacity(0.5),
                    ),
                  ),
                );
              },
            ),
          )
        else
          Container(
            height: 180,
            width: double.infinity,
            color: statusColor.withOpacity(0.1),
            child: Center(
              child: Icon(
                isLost ? Icons.search : Icons.inventory_2,
                size: 80,
                color: statusColor.withOpacity(0.5),
              ),
            ),
          ),
        if (item.imageUrl != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildItemTitle(Item item, Color statusColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(item.dateTime),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.itemName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          if (item.description != null && item.description!.isNotEmpty)
            Text(
              item.description!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemDetails(Item item, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          if (item.location != null && item.location!.isNotEmpty)
            _buildInfoRow(Icons.location_on_outlined, 'Location',
                item.location!, statusColor),
          if (item.geotag != null && item.geotag!.isNotEmpty)
            InkWell(
              onTap: () => _launchMap(item.geotag!),
              child: _buildInfoRow(Icons.map_outlined, 'View on Map',
                  'Tap to view full map', statusColor,
                  isButton: true),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, Color color,
      {bool isButton = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isButton ? FontWeight.w600 : FontWeight.normal,
                    color: isButton ? color : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (isButton) Icon(Icons.arrow_forward_ios, size: 16, color: color),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return GestureDetector(
      onTap: () => _launchMap(_itemLocation!.toString()),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: _itemLocation!,
            initialZoom: 15.0,
            // interactiveFlags:
            //     InteractiveFlag.all & ~InteractiveFlag.rotate, // Disable rotation
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // Updated OSM URL
              userAgentPackageName: 'com.example.lostandfound',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _itemLocation!,
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(bool isLost, Color statusColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  isLost ? Icons.info_outline : Icons.help_outline,
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isLost
                        ? 'Have you found this item? Tap the button below to contact the owner.'
                        : 'Is this your item? Tap the button below to contact the finder.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Full-screen map dialog
class FullScreenMapDialog extends StatefulWidget {
  final latlng.LatLng location;

  const FullScreenMapDialog({required this.location, super.key});

  @override
  _FullScreenMapDialogState createState() => _FullScreenMapDialogState();
}

class _FullScreenMapDialogState extends State<FullScreenMapDialog> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.location,
              initialZoom: 15.0,
              // interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.lostandfound',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.location,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () => Navigator.of(context).pop(false), // Close dialog
              child: const Icon(Icons.close, color: Colors.black),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () =>
                  Navigator.of(context).pop(true), // Open Google Maps
              child: const Icon(Icons.open_in_new, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    _mapController.move(
                        widget.location, _mapController.camera.zoom + 1);
                  },
                  child: const Icon(Icons.zoom_in, color: Colors.black),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    _mapController.move(
                        widget.location, _mapController.camera.zoom - 1);
                  },
                  child: const Icon(Icons.zoom_out, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
