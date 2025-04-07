// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lostandfound/widget/logout.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final VoidCallback onSearchToggle;
  final TextEditingController searchController;
  final TabController tabController;
  final int currentIndex;
  final Color primaryColor;
  final Color accentColor;

  const HomeAppBar({
    super.key,
    required this.isSearching,
    required this.onSearchToggle,
    required this.searchController,
    required this.tabController,
    required this.currentIndex,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearching && currentIndex == 0
          ? _buildSearchField()
          : _buildTitle(),
      backgroundColor: primaryColor,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, accentColor],
            stops: const [0.2, 1.0],
          ),
        ),
      ),
      actions: currentIndex == 0
          ? [
              IconButton(
                icon: Icon(
                  isSearching ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
                onPressed: onSearchToggle,
                tooltip: 'Search',
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.logout_outlined, color: Colors.white),
                  onPressed: () => LogoutDialog.show(context),
                  tooltip: 'Logout',
                ),
              ),
            ]
          : [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.logout_outlined, color: Colors.white),
                  onPressed: () => LogoutDialog.show(context),
                  tooltip: 'Logout',
                ),
              ),
            ],
      bottom: currentIndex == 0 ? _buildTabBar() : null,
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white38),
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () => searchController.clear(),
                )
              : null,
        ),
        style: const TextStyle(color: Colors.white),
        autofocus: true,
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Image.asset(
          'asset/images/logo.png',
          height: 32,
          width: 32,
          color: Colors.white,
        ),
        const SizedBox(width: 12),
        Text(
          currentIndex == 0
              ? 'Find Me'
              : currentIndex == 1
                  ? 'Add Item'
                  : currentIndex == 2
                      ? 'Profile'
                      : 'Matches',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  PreferredSize _buildTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(58),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, accentColor],
            stops: const [0.2, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: TabBar(
            controller: tabController,
            indicatorPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              _buildTab('ALL', Icons.all_inclusive, Colors.white),
              _buildTab('LOST', Icons.search, const Color(0xFFE53935)),
              _buildTab('FOUND', Icons.check_circle, const Color(0xFF43A047)),
            ],
          ),
        ),
      ),
    );
  }

  Tab _buildTab(String title, IconData icon, Color iconColor) {
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

  @override
  Size get preferredSize =>
      Size.fromHeight(currentIndex == 0 ? 110 : kToolbarHeight);
}
