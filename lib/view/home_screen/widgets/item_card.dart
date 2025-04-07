// ignore_for_file: deprecated_member_use, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lostandfound/model/item_model.dart';
import 'package:lostandfound/view/add_items/add_items_provider/add_items_provider.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final ItemProvider provider;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Color lostColor;
  final Color foundColor;

  const ItemCard({
    required this.item,
    required this.provider,
    required this.onTap,
    required this.onLongPress,
    required this.lostColor,
    required this.foundColor,
  });

  String _formatDate(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLost = item.type.toLowerCase() == 'lost';
    final Color statusColor = isLost ? lostColor : foundColor;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              _buildImageSection(context, isLost, statusColor),
              const SizedBox(width: 12),

              // Details section
              Expanded(
                child: _buildDetailsSection(isLost, statusColor),
              ),
              const SizedBox(width: 8),

              // Chevron icon
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: statusColor.withOpacity(0.6),
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(
      BuildContext context, bool isLost, Color statusColor) {
    return Hero(
      tag: 'item-image-${item.id}',
      child: SizedBox(
        width: 100,
        height: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: item.imageUrl != null
                    ? Image.network(
                        '${provider.baseUrl}/static/uploads/${item.imageUrl}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(isLost),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: statusColor,
                              strokeWidth: 2,
                            ),
                          );
                        },
                      )
                    : _buildPlaceholderImage(isLost),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    isLost ? '🔍 Lost' : '✅ Found',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(bool isLost, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Ensure it takes only required space
      children: [
        Text(
          item.itemName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF303030),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (item.description != null && item.description!.isNotEmpty)
          Text(
            item.description!,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (item.location != null && item.location!.isNotEmpty)
              // _buildChip(
              //   Icons.location_on_outlined,
              //   item.location!,
              //   statusColor,
              // ),
              _buildChip(
                Icons.calendar_today_rounded,
                _formatDate(item.dateTime),
                Colors.grey[700]!,
                backgroundColor: Colors.grey[200]!,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(IconData icon, String text, Color color,
      {Color? backgroundColor}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 140), // Adjusted maxWidth
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isLost) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          isLost ? Icons.search_rounded : Icons.inventory_2_rounded,
          color: Colors.grey[400],
          size: 36,
        ),
      ),
    );
  }
}
