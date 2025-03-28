// // ignore_for_file: library_private_types_in_public_api, deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/services.dart';

// // Assuming these are your custom imports - replace with actual paths
// import 'package:lostandfound/model/item_model.dart';
// import 'package:lostandfound/view/add_items/add_items_provider/add_items_provider.dart';
// import 'package:lostandfound/view/create_new_item/create_new_item.dart';
// import 'package:lostandfound/view/get_single_item/get_single_item_view.dart';
// import 'package:lostandfound/view/home_screen/home_screen_provider/home_screen_provider.dart';
// import 'package:lostandfound/view/my_data/my_data.dart';
// import 'package:lostandfound/widget/logout.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _searchController = TextEditingController();
//   bool _isSearching = false;

//   // Colors
//   final Color _primaryColor = const Color(0xFF3949AB); // Indigo 600
//   final Color _accentColor = const Color(0xFF1E88E5); // Blue 600
//   final Color _backgroundColor = const Color(0xFFF5F7FA);
//   final Color _cardColor = Colors.white;
//   final Color _lostColor = const Color(0xFFE53935); // Red 600
//   final Color _foundColor = const Color(0xFF43A047); // Green 600

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);

//     // Set status bar color to match app theme
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarColor: _primaryColor,
//       statusBarIconBrightness: Brightness.light,
//     ));

//     Future.microtask(() {
//       Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
//       Provider.of<ItemProvider>(context, listen: false).getAllItems();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _showCreateItemDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => CreateItemDialog(),
//     );
//   }

//   void _navigateToItemDetails(BuildContext context, int itemId) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ItemDetailsScreen(itemId: itemId),
//       ),
//     );
//   }

//   void _navigateToMyItems(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => MyItemsScreen()),
//     );
//   }

//   String _formatDate(String dateTime) {
//     try {
//       final date = DateTime.parse(dateTime);
//       return DateFormat('MMM d, yyyy').format(date);
//     } catch (e) {
//       return dateTime;
//     }
//   }

//   List<Item> _getFilteredItems(List<Item> items) {
//     if (_searchController.text.isEmpty) {
//       return items;
//     }

//     final query = _searchController.text.toLowerCase();
//     return items
//         .where((item) =>
//             item.itemName.toLowerCase().contains(query) ||
//             (item.location != null &&
//                 item.location!.toLowerCase().contains(query)) ||
//             (item.description != null &&
//                 item.description!.toLowerCase().contains(query)))
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       appBar: AppBar(
//         title: _isSearching
//             ? Container(
//                 height: 40,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(24),
//                   border: Border.all(color: Colors.white38, width: 1),
//                 ),
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: 'Search items...',
//                     hintStyle: const TextStyle(color: Colors.white70),
//                     border: InputBorder.none,
//                     contentPadding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     prefixIcon: const Icon(Icons.search,
//                         color: Colors.white70, size: 20),
//                     suffixIcon: _searchController.text.isNotEmpty
//                         ? IconButton(
//                             icon: const Icon(Icons.clear,
//                                 color: Colors.white70, size: 18),
//                             onPressed: () {
//                               _searchController.clear();
//                               setState(() {});
//                             },
//                             padding: EdgeInsets.zero,
//                           )
//                         : null,
//                   ),
//                   style: const TextStyle(color: Colors.white, fontSize: 16),
//                   autofocus: true,
//                   onChanged: (value) => setState(() {}),
//                 ),
//               )
//             : Row(
//                 children: [
//                   Image.asset(
//                     'asset/images/logo.png',
//                     height: 32,
//                     width: 32,
//                     color: Colors.white,
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'Find Me',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                       color: Colors.white,
//                       letterSpacing: 0.5,
//                       shadows: [
//                         Shadow(
//                           offset: Offset(0, 1),
//                           blurRadius: 3,
//                           color: Colors.black38,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//         backgroundColor: _primaryColor,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [_primaryColor, _accentColor],
//               stops: const [0.2, 1.0],
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               _isSearching ? Icons.close : Icons.search,
//               color: Colors.white,
//               size: 24,
//             ),
//             onPressed: () {
//               setState(() {
//                 _isSearching = !_isSearching;
//                 if (!_isSearching) _searchController.clear();
//               });
//             },
//             tooltip: 'Search',
//             splashRadius: 24,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//               child: ElevatedButton.icon(
//                 onPressed: () => _navigateToMyItems(context),
//                 icon: const Icon(Icons.inventory, size: 18),
//                 label: const Text('My Items'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white.withOpacity(0.2),
//                   foregroundColor: Colors.white,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   elevation: 0,
//                   shadowColor: Colors.transparent,
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(right: 8.0),
//             child: IconButton(
//               icon: const Icon(Icons.logout_outlined,
//                   color: Colors.white, size: 24),
//               onPressed: () => LogoutDialog.show(context),
//               tooltip: 'Logout',
//               splashRadius: 24,
//             ),
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(58),
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [_primaryColor, _accentColor],
//                 stops: const [0.2, 1.0],
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   offset: const Offset(0, 2),
//                   blurRadius: 4,
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//               child: TabBar(
//                 controller: _tabController,
//                 indicator: BoxDecoration(
//                   borderRadius: BorderRadius.circular(50),
//                   color: Colors.white.withOpacity(0.25),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       offset: const Offset(0, 1),
//                       blurRadius: 2,
//                     ),
//                   ],
//                 ),
//                 indicatorPadding:
//                     const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                 labelColor: Colors.white,
//                 unselectedLabelColor: Colors.white70,
//                 labelStyle: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                   letterSpacing: 0.5,
//                 ),
//                 tabs: [
//                   _buildTab('ALL', Icons.all_inclusive, Colors.white),
//                   _buildTab('LOST', Icons.search, _lostColor),
//                   _buildTab('FOUND', Icons.check_circle, _foundColor),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           color: _backgroundColor,
//         ),
//         child: Consumer<ItemProvider>(
//           builder: (context, itemProvider, child) {
//             if (itemProvider.isLoading) {
//               return _buildLoadingState();
//             } else if (itemProvider.error != null) {
//               return _buildErrorState(
//                 itemProvider.error!,
//                 () => itemProvider.getAllItems(),
//               );
//             } else if (itemProvider.items.isEmpty) {
//               return _buildEmptyState(
//                 Icons.inventory_2_outlined,
//                 'No items available',
//                 'Add a new item to get started',
//               );
//             } else {
//               // Apply search filtering to all tabs
//               final filteredItems = _getFilteredItems(itemProvider.items);

//               return TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildAllTab(filteredItems),
//                   _buildLostTab(filteredItems),
//                   _buildFoundTab(filteredItems),
//                 ],
//               );
//             }
//           },
//         ),
//       ),
//       floatingActionButton: AnimatedScale(
//         scale: 1.0,
//         duration: const Duration(milliseconds: 200),
//         child: FloatingActionButton.extended(
//           onPressed: () => _showCreateItemDialog(context),
//           backgroundColor: _accentColor,
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           icon: const Icon(Icons.add, color: Colors.white, size: 24),
//           label: const Text(
//             'New Item',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//               fontSize: 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTab(String title, IconData icon, Color iconColor) {
//     return Tab(
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 18, color: iconColor),
//           const SizedBox(width: 8),
//           Text(title),
//         ],
//       ),
//     );
//   }

//   Widget _buildAllTab(List<Item> items) {
//     if (items.isEmpty) {
//       if (_searchController.text.isNotEmpty) {
//         return _buildEmptyState(
//           Icons.search_off,
//           'No matches found',
//           'Try a different search term',
//         );
//       }
//       return _buildEmptyState(
//         Icons.all_inclusive,
//         'No items available',
//         'Add a new item to get started',
//       );
//     }
//     return _buildItemList(items, 'All Items', _accentColor);
//   }

//   Widget _buildLostTab(List<Item> items) {
//     final lostItems =
//         items.where((item) => item.type.toLowerCase() == 'lost').toList();
//     if (lostItems.isEmpty) {
//       if (_searchController.text.isNotEmpty) {
//         return _buildEmptyState(
//           Icons.search_off,
//           'No matches found',
//           'Try a different search term',
//         );
//       }
//       return _buildEmptyState(
//         Icons.search,
//         'No lost items',
//         'Add a lost item to get started',
//       );
//     }
//     return _buildItemList(lostItems, 'Lost Items', _lostColor);
//   }

//   Widget _buildFoundTab(List<Item> items) {
//     final foundItems =
//         items.where((item) => item.type.toLowerCase() == 'found').toList();
//     if (foundItems.isEmpty) {
//       if (_searchController.text.isNotEmpty) {
//         return _buildEmptyState(
//           Icons.search_off,
//           'No matches found',
//           'Try a different search term',
//         );
//       }
//       return _buildEmptyState(
//         Icons.check_circle,
//         'No found items',
//         'Add a found item to get started',
//       );
//     }
//     return _buildItemList(foundItems, 'Found Items', _foundColor);
//   }

//   Widget _buildItemList(List<Item> items, String title, Color themeColor) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: themeColor,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: themeColor.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: themeColor.withOpacity(0.1),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Text(
//                   '${items.length} ${items.length == 1 ? 'item' : 'items'}',
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: themeColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: RefreshIndicator(
//             onRefresh: () =>
//                 Provider.of<ItemProvider>(context, listen: false).getAllItems(),
//             color: themeColor,
//             child: ListView.builder(
//               padding: const EdgeInsets.only(top: 4, bottom: 100),
//               itemCount: items.length,
//               itemBuilder: (context, index) {
//                 return _buildItemCard(
//                   context,
//                   items[index],
//                   Provider.of<ItemProvider>(context, listen: false),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildItemCard(
//       BuildContext context, Item item, ItemProvider provider) {
//     final bool isLost = item.type.toLowerCase() == 'lost';
//     final Color statusColor = isLost ? _lostColor : _foundColor;
//     final String statusIcon = isLost ? '🔍' : '✅';

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       child: Card(
//         elevation: 3,
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: BorderSide(
//             color: Colors.grey.withOpacity(0.1),
//             width: 1,
//           ),
//         ),
//         child: InkWell(
//           onTap: () => _navigateToItemDetails(context, item.id),
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Hero(
//                   tag: 'item-image-${item.id}',
//                   child: Container(
//                     width: 110,
//                     height: 110,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.3),
//                           spreadRadius: 1,
//                           blurRadius: 6,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Stack(
//                         children: [
//                           Positioned.fill(
//                             child: item.imageUrl != null
//                                 ? Image.network(
//                                     '${provider.baseUrl}/static/uploads/${item.imageUrl}',
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return _buildPlaceholderImage(isLost);
//                                     },
//                                     loadingBuilder:
//                                         (context, child, loadingProgress) {
//                                       if (loadingProgress == null) return child;
//                                       return Container(
//                                         color: Colors.grey[200],
//                                         child: Center(
//                                           child: CircularProgressIndicator(
//                                             value: loadingProgress
//                                                         .expectedTotalBytes !=
//                                                     null
//                                                 ? loadingProgress
//                                                         .cumulativeBytesLoaded /
//                                                     loadingProgress
//                                                         .expectedTotalBytes!
//                                                 : null,
//                                             strokeWidth: 2,
//                                             color: statusColor,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   )
//                                 : _buildPlaceholderImage(isLost),
//                           ),
//                           Positioned(
//                             top: 8,
//                             left: 8,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: statusColor.withOpacity(0.9),
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.2),
//                                     spreadRadius: 0,
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 1),
//                                   ),
//                                 ],
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(
//                                     statusIcon,
//                                     style: const TextStyle(fontSize: 10),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     StringExtension(item.type).capitalize(),
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 10,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         item.itemName,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: Color(0xFF303030),
//                           height: 1.3,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 8),
//                       if (item.description != null &&
//                           item.description!.isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(bottom: 8),
//                           child: Text(
//                             item.description!,
//                             style: TextStyle(
//                               color: Colors.grey[700],
//                               fontSize: 14,
//                               height: 1.3,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       if (item.location != null && item.location!.isNotEmpty)
//                         Container(
//                           margin: const EdgeInsets.only(bottom: 8),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: statusColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.location_on_outlined,
//                                 size: 16,
//                                 color: statusColor,
//                               ),
//                               const SizedBox(width: 4),
//                               Flexible(
//                                 child: Text(
//                                   item.location!,
//                                   style: TextStyle(
//                                     color: statusColor,
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.calendar_today,
//                             size: 14,
//                             color: Colors.grey[600],
//                           ),
//                           const SizedBox(width: 4),
//                           Flexible(
//                             child: Text(
//                               _formatDate(item.dateTime),
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: Icon(
//                     Icons.chevron_right,
//                     color: statusColor.withOpacity(0.6),
//                     size: 20,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPlaceholderImage(bool isLost) {
//     return Container(
//       color: Colors.grey[200],
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               isLost ? Icons.search : Icons.inventory_2,
//               color: Colors.grey[400],
//               size: 36,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               isLost ? 'Lost' : 'Found',
//               style: TextStyle(
//                 color: Colors.grey[500],
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(IconData icon, String message, String subMessage) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(28),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: _primaryColor.withOpacity(0.1),
//               boxShadow: [
//                 BoxShadow(
//                   color: _primaryColor.withOpacity(0.1),
//                   blurRadius: 20,
//                   spreadRadius: 5,
//                 ),
//               ],
//             ),
//             child: Icon(
//               icon,
//               color: _primaryColor,
//               size: 68,
//             ),
//           ),
//           const SizedBox(height: 28),
//           Text(
//             message,
//             style: const TextStyle(
//               fontSize: 24,
//               color: Color(0xFF303030),
//               fontWeight: FontWeight.bold,
//               letterSpacing: 0.5,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Text(
//               subMessage,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF757575),
//                 height: 1.4,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(height: 36),
//           ElevatedButton.icon(
//             onPressed: () => _showCreateItemDialog(context),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _accentColor,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 4,
//               shadowColor: _accentColor.withOpacity(0.4),
//             ),
//             icon: const Icon(Icons.add, size: 20),
//             label: const Text(
//               'Add Item',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 60,
//             height: 60,
//             child: CircularProgressIndicator(
//               color: _accentColor,
//               strokeWidth: 3,
//               backgroundColor: Colors.grey[200],
//             ),
//           ),
//           const SizedBox(height: 28),
//           Text(
//             'Loading items...',
//             style: TextStyle(
//               color: _primaryColor,
//               fontSize: 20,
//               fontWeight: FontWeight.w500,
//               letterSpacing: 0.5,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Please wait',
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(String error, VoidCallback onRetry) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.red[50],
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.red.withOpacity(0.2),
//                     blurRadius: 20,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.error_outline,
//                 color: Colors.redAccent,
//                 size: 60,
//               ),
//             ),
//             const SizedBox(height: 28),
//             const Text(
//               'Oops! Something went wrong',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF303030),
//                 letterSpacing: 0.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Text(
//                 error,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Color(0xFF757575),
//                   height: 1.4,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(height: 36),
//             ElevatedButton.icon(
//               onPressed: onRetry,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _accentColor,
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 4,
//                 shadowColor: _accentColor.withOpacity(0.4),
//               ),
//               icon: const Icon(Icons.refresh, size: 20),
//               label: const Text(
//                 'Retry',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lostandfound/view/police_view/police_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// Assuming these are your custom imports - replace with actual paths
import 'package:lostandfound/model/item_model.dart';
import 'package:lostandfound/view/add_items/add_items_provider/add_items_provider.dart';
import 'package:lostandfound/view/create_new_item/create_new_item.dart';
import 'package:lostandfound/view/get_single_item/get_single_item_view.dart';
import 'package:lostandfound/view/home_screen/home_screen_provider/home_screen_provider.dart';
import 'package:lostandfound/view/my_data/my_data.dart';
import 'package:lostandfound/widget/logout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _currentIndex = 0; // For bottom navigation

  // Colors
  final Color _primaryColor = const Color(0xFF3949AB);
  final Color _accentColor = const Color(0xFF1E88E5);
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _lostColor = const Color(0xFFE53935);
  final Color _foundColor = const Color(0xFF43A047);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _primaryColor,
      statusBarIconBrightness: Brightness.light,
    ));

    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<ItemProvider>(context, listen: false).getAllItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateItemDialog(),
    );
  }

  void _navigateToItemDetails(BuildContext context, int itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsScreen(itemId: itemId),
      ),
    );
  }

  String _formatDate(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateTime;
    }
  }

  List<Item> _getFilteredItems(List<Item> items) {
    if (_searchController.text.isEmpty) {
      return items;
    }

    final query = _searchController.text.toLowerCase();
    return items
        .where((item) =>
            item.itemName.toLowerCase().contains(query) ||
            (item.location != null &&
                item.location!.toLowerCase().contains(query)) ||
            (item.description != null &&
                item.description!.toLowerCase().contains(query)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
  backgroundColor: _primaryColor,
  icon: const Icon(
    Icons.emergency_outlined, 
    color: Colors.white,
    size: 28,
  ),
  label: Text(
    "Emergency",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
  elevation: 6,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PolicePage(),
    ),
  ),
),
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: _isSearching && _currentIndex == 0
            ? Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white38, width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    prefixIcon: const Icon(Icons.search,
                        color: Colors.white70, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Colors.white70, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            padding: EdgeInsets.zero,
                          )
                        : null,
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  autofocus: true,
                  onChanged: (value) => setState(() {}),
                ),
              )
            : Row(
                children: [
                  Image.asset(
                    'asset/images/logo.png',
                    height: 32,
                    width: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _currentIndex == 0
                        ? 'Find Me'
                        : _currentIndex == 1
                            ? 'Add Item'
                            : 'Profile',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        backgroundColor: _primaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryColor, _accentColor],
              stops: const [0.2, 1.0],
            ),
          ),
        ),
        actions: _currentIndex == 0
            ? [
                IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) _searchController.clear();
                    });
                  },
                  tooltip: 'Search',
                  splashRadius: 24,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout_outlined,
                        color: Colors.white, size: 24),
                    onPressed: () => LogoutDialog.show(context),
                    tooltip: 'Logout',
                    splashRadius: 24,
                  ),
                ),
              ]
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout_outlined,
                        color: Colors.white, size: 24),
                    onPressed: () => LogoutDialog.show(context),
                    tooltip: 'Logout',
                    splashRadius: 24,
                  ),
                ),
              ],
        bottom: _currentIndex == 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(58),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_primaryColor, _accentColor],
                      stops: const [0.2, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white.withOpacity(0.25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      indicatorPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                      tabs: [
                        _buildTab('ALL', Icons.all_inclusive, Colors.white),
                        _buildTab('LOST', Icons.search, _lostColor),
                        _buildTab('FOUND', Icons.check_circle, _foundColor),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                if (index != 0) {
                  _isSearching = false;
                  _searchController.clear();
                }
              });
              if (index == 1) {
                _showCreateItemDialog(context);
              }
            },
            selectedItemColor: _accentColor,
            unselectedItemColor: Colors.grey.shade400,
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 11,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add_rounded, color: _accentColor),
                ),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildAddContent();
      case 2:
        return MyItemsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Consumer<ItemProvider>(
      builder: (context, itemProvider, child) {
        if (itemProvider.isLoading) {
          return _buildLoadingState();
        } else if (itemProvider.error != null) {
          return _buildErrorState(
            itemProvider.error!,
            () => itemProvider.getAllItems(),
          );
        } else if (itemProvider.items.isEmpty) {
          return _buildEmptyState(
            Icons.inventory_2_outlined,
            'No items available',
            'Add a new item to get started',
          );
        } else {
          final filteredItems = _getFilteredItems(itemProvider.items);
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllTab(filteredItems),
              _buildLostTab(filteredItems),
              _buildFoundTab(filteredItems),
            ],
          );
        }
      },
    );
  }

  Widget _buildAddContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 80,
            color: _accentColor,
          ),
          const SizedBox(height: 20),
          const Text(
            'Add New Item',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF303030),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap the button below to report a lost or found item',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateItemDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              'Create New Item',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder method - replace with your actual user ID retrieval logic
  String getCurrentUserId() {
    // This should return the current user's ID from your authentication system
    return "current_user_id"; // Replace with actual implementation
  }

  Widget _buildTab(String title, IconData icon, Color iconColor) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildAllTab(List<Item> items) {
    if (items.isEmpty) {
      if (_searchController.text.isNotEmpty) {
        return _buildEmptyState(
          Icons.search_off,
          'No matches found',
          'Try a different search term',
        );
      }
      return _buildEmptyState(
        Icons.all_inclusive,
        'No items available',
        'Add a new item to get started',
      );
    }
    return _buildItemList(items, 'All Items', _accentColor);
  }

  Widget _buildLostTab(List<Item> items) {
    final lostItems =
        items.where((item) => item.type.toLowerCase() == 'lost').toList();
    if (lostItems.isEmpty) {
      if (_searchController.text.isNotEmpty) {
        return _buildEmptyState(
          Icons.search_off,
          'No matches found',
          'Try a different search term',
        );
      }
      return _buildEmptyState(
        Icons.search,
        'No lost items',
        'Add a lost item to get started',
      );
    }
    return _buildItemList(lostItems, 'Lost Items', _lostColor);
  }

  Widget _buildFoundTab(List<Item> items) {
    final foundItems =
        items.where((item) => item.type.toLowerCase() == 'found').toList();
    if (foundItems.isEmpty) {
      if (_searchController.text.isNotEmpty) {
        return _buildEmptyState(
          Icons.search_off,
          'No matches found',
          'Try a different search term',
        );
      }
      return _buildEmptyState(
        Icons.check_circle,
        'No found items',
        'Add a found item to get started',
      );
    }
    return _buildItemList(foundItems, 'Found Items', _foundColor);
  }

  Widget _buildItemList(List<Item> items, String title, Color themeColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: themeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                Provider.of<ItemProvider>(context, listen: false).getAllItems(),
            color: themeColor,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 100),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildItemCard(
                  context,
                  items[index],
                  Provider.of<ItemProvider>(context, listen: false),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(
      BuildContext context, Item item, ItemProvider provider) {
    final bool isLost = item.type.toLowerCase() == 'lost';
    final Color statusColor = isLost ? _lostColor : _foundColor;
    final String statusIcon = isLost ? '🔍' : '✅';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => _navigateToItemDetails(context, item.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'item-image-${item.id}',
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: item.imageUrl != null
                                ? Image.network(
                                    '${provider.baseUrl}/static/uploads/${item.imageUrl}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildPlaceholderImage(isLost);
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                            color: statusColor,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : _buildPlaceholderImage(isLost),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    statusIcon,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    StringExtension(item.type).capitalize(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF303030),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (item.description != null &&
                          item.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            item.description!,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (item.location != null && item.location!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  item.location!,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _formatDate(item.dateTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.chevron_right,
                    color: statusColor.withOpacity(0.6),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isLost) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLost ? Icons.search : Icons.inventory_2,
              color: Colors.grey[400],
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              isLost ? 'Lost' : 'Found',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message, String subMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryColor.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: _primaryColor,
              size: 68,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            message,
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFF303030),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 36),
          ElevatedButton.icon(
            onPressed: () => _showCreateItemDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: _accentColor.withOpacity(0.4),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Add Item',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: _accentColor,
              strokeWidth: 3,
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Loading items...',
            style: TextStyle(
              color: _primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Please wait',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red[50],
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 60,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF303030),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                error,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF757575),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: _accentColor.withOpacity(0.4),
              ),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text(
                'Retry',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
