// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:lostandfound/view/add_profile/profile_screen.dart';
import 'package:lostandfound/view/get_single_item/get_single_item_view.dart';
import 'package:lostandfound/view/home_screen/widgets/home_appbar.dart';
import 'package:lostandfound/view/home_screen/widgets/home_bottom_navigationbar.dart';
import 'package:lostandfound/view/home_screen/widgets/item_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:lostandfound/model/item_model.dart';
import 'package:lostandfound/view/add_items/add_items_provider/add_items_provider.dart';
import 'package:lostandfound/view/create_new_item/create_new_item.dart';
import 'package:lostandfound/view/home_screen/home_screen_provider/home_screen_provider.dart';
import 'package:lostandfound/view/my_data/my_data.dart';
import 'package:lostandfound/view/police_view/police_view.dart';

import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _currentIndex = 0;
  // ignore: unused_field
  int? _selectedItemId;

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
        ));
  }

  List<Item> _getFilteredItems(List<Item> items) {
    if (_searchController.text.isEmpty) return items;
    final query = _searchController.text.toLowerCase();
    return items
        .where((item) =>
            item.itemName.toLowerCase().contains(query) ||
            (item.location?.toLowerCase().contains(query) ?? false) ||
            (item.description?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryColor,
        icon: const Icon(Icons.emergency_outlined, color: Colors.white),
        label: const Text("Add", style: TextStyle(color: Colors.white)),
        onPressed: () =>
            _showCreateItemDialog(context), // Updated to show dialog
      ),
      backgroundColor: _backgroundColor,
      appBar: HomeAppBar(
        isSearching: _isSearching,
        onSearchToggle: () {
          setState(() {
            _isSearching = !_isSearching;
            if (!_isSearching) _searchController.clear();
          });
        },
        searchController: _searchController,
        tabController: _tabController,
        currentIndex: _currentIndex,
        primaryColor: _primaryColor,
        accentColor: _accentColor,
      ),
      body: _buildBody(),
      bottomNavigationBar: HomeBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index != 0) {
              _isSearching = false;
              _searchController.clear();
            }
          });
          // No need to handle index 1 here, as _buildBody handles it
        },
        accentColor: _accentColor,
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return Consumer<ItemProvider>(
          builder: (context, itemProvider, child) {
            final filteredItems = _getFilteredItems(itemProvider.items);
            return TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(filteredItems, 'all'),
                _buildTabContent(filteredItems, 'lost'),
                _buildTabContent(filteredItems, 'found'),
              ],
            );
          },
        );
      case 1:
        return MyItemsScreen(); // Updated to show PolicePage
      case 2:
        return PolicePage();
      case 3:
        return const ProfileScreenContent();
      default:
        return Container();
    }
  }

  Widget _buildTabContent(List<Item> items, String type) {
    final filteredItems = type == 'all'
        ? items
        : items.where((item) => item.type.toLowerCase() == type).toList();
    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return ItemCard(
          item: filteredItems[index],
          provider: Provider.of<ItemProvider>(context, listen: false),
          onTap: () => _navigateToItemDetails(context, filteredItems[index].id),
          onLongPress: () {
            setState(() {
              _selectedItemId = filteredItems[index].id;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Selected "${filteredItems[index].itemName}" for matching'),
              ),
            );
          },
          lostColor: _lostColor,
          foundColor: _foundColor,
        );
      },
    );
  }
}
