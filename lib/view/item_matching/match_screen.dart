import 'package:flutter/material.dart';
import 'package:lostandfound/view/item_matching/matching_criteria_provider/matching%20criteria_provider.dart';
import 'package:lostandfound/view/user_match/user_match_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchesScreen extends StatefulWidget {
  final int itemId;

  const MatchesScreen({required this.itemId, super.key});

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId().then((userId) {
      setState(() => _userId = userId);
      if (userId != null) {
        Provider.of<UserMatchesProvider>(context, listen: false)
            .getUserMatches(userId);
      }
    });
    Future.microtask(() {
      final matchesProvider =
          Provider.of<MatchesProvider>(context, listen: false);
      matchesProvider.clear();
      matchesProvider.getMatches(widget.itemId);
    });
  }

  Future<int?> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id'); // Assumes user_id is stored on login
  }

  Future<void> _createMatch(int lostId, int foundId) async {
    final userMatchesProvider =
        Provider.of<UserMatchesProvider>(context, listen: false);
    bool success = await userMatchesProvider.createMatch(lostId, foundId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                userMatchesProvider.message ?? 'Match created successfully')),
      );
      if (_userId != null) {
        userMatchesProvider
            .getUserMatches(_userId!); // Refresh confirmed matches
      }
      // Optionally refresh potential matches
      Provider.of<MatchesProvider>(context, listen: false)
          .getMatches(widget.itemId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(userMatchesProvider.error ?? 'Failed to create match')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        centerTitle: true,
        elevation: 0,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: 'Potential Matches'),
                Tab(text: 'Confirmed Matches'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPotentialMatchesTab(),
                  _buildConfirmedMatchesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPotentialMatchesTab() {
    return Consumer<MatchesProvider>(
      builder: (context, matchesProvider, child) {
        if (matchesProvider.isLoading) {
          return _buildLoadingState('Searching for potential matches...');
        } else if (matchesProvider.error != null) {
          return _buildErrorState(matchesProvider);
        } else if (matchesProvider.item == null) {
          return _buildItemNotFoundState();
        } else if (matchesProvider.matches.isEmpty) {
          return _buildNoMatchesState(matchesProvider);
        } else {
          return _buildPotentialMatchesList(matchesProvider);
        }
      },
    );
  }

  Widget _buildConfirmedMatchesTab() {
    return Consumer<UserMatchesProvider>(
      builder: (context, userMatchesProvider, child) {
        if (_userId == null) {
          return const Center(child: Text('User ID not available'));
        }
        if (userMatchesProvider.isLoading) {
          return _buildLoadingState('Loading confirmed matches...');
        } else if (userMatchesProvider.error != null) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red[400], size: 60),
                  const SizedBox(height: 20),
                  Text(
                    'Error Loading Matches',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userMatchesProvider.error!,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        userMatchesProvider.getUserMatches(_userId!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Try Again',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        } else if (userMatchesProvider.matches.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 80, color: Colors.blue[200]),
                  const SizedBox(height: 24),
                  Text(
                    'No Confirmed Matches',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You haven\'t confirmed any matches yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else {
          return _buildConfirmedMatchesList(userMatchesProvider);
        }
      },
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(MatchesProvider provider) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 60),
            const SizedBox(height: 20),
            Text(
              'Error Loading Matches',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.error!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.getMatches(widget.itemId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Try Again',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemNotFoundState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.orange[400]),
            const SizedBox(height: 20),
            const Text(
              'Item Not Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'The specified item ID might be invalid or deleted.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMatchesState(MatchesProvider provider) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.blue[200]),
            const SizedBox(height: 24),
            Text(
              'No Potential Matches Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t find any potential matches for "${provider.item!.itemName}" yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child:
                  const Text('Go Back', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPotentialMatchesList(MatchesProvider provider) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    _buildItemImage(provider.item!.imageUrl, provider.baseUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.item!.itemName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.item!.type.capitalize(),
                            style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500),
                          ),
                          if (provider.item!.location != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      provider.item!.location!,
                                      style: TextStyle(color: Colors.grey[600]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
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
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24), child: Divider()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${provider.matches.length} Potential Match${provider.matches.length > 1 ? 'es' : ''} Found',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: provider.matches.length,
              itemBuilder: (context, index) {
                return _buildPotentialMatchCard(provider, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedMatchesList(UserMatchesProvider provider) {
    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.matches.length,
        itemBuilder: (context, index) {
          final match = provider.matches[index];
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match ID: ${match.matchId}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Lost: ${match.lostItemName}',
                      style: TextStyle(color: Colors.grey[800])),
                  Text('Description: ${match.lostDescription}',
                      style: TextStyle(color: Colors.grey[600])),
                  Text('Location: ${match.lostLocation}',
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Found: ${match.foundItemName}',
                      style: TextStyle(color: Colors.grey[800])),
                  Text('Description: ${match.foundDescription}',
                      style: TextStyle(color: Colors.grey[600])),
                  Text('Location: ${match.foundLocation}',
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Matched on: ${match.matchDate}',
                      style: TextStyle(color: Colors.blue[700])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemImage(String? imageUrl, String baseUrl) {
    return imageUrl != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              '$baseUrl/static/uploads/$imageUrl',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderImage(70),
            ),
          )
        : _buildPlaceholderImage(70);
  }

  Widget _buildPlaceholderImage(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildPotentialMatchCard(MatchesProvider provider, int index) {
    final match = provider.matches[index];
    final matchedItem = match.matchedItem;
    final criteria = match.matchCriteria;

    double score = (criteria.descriptionSimilarityScore * 0.5) +
        (criteria.categoryMatch ? 0.2 : 0) +
        (criteria.locationMatch ? 0.2 : 0) +
        (criteria.nameSimilarity ? 0.1 : 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemImage(matchedItem.imageUrl, provider.baseUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          matchedItem.itemName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          matchedItem.type.capitalize(),
                          style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500),
                        ),
                        if (matchedItem.location != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    matchedItem.location!,
                                    style: TextStyle(color: Colors.grey[600]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getScoreColor(score),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(score * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _createMatch(
                          provider.item!.type.toLowerCase() == 'lost'
                              ? provider.item!.id
                              : matchedItem.id,
                          provider.item!.type.toLowerCase() == 'found'
                              ? provider.item!.id
                              : matchedItem.id,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Confirm',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Match Details:',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              const SizedBox(height: 8),
              _buildMatchCriteria(criteria),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCriteria(dynamic criteria) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (criteria.categoryMatch)
          _buildMatchChip('Category Match', Icons.category, Colors.green),
        if (criteria.descriptionMatch)
          _buildMatchChip('Description Match', Icons.description, Colors.blue),
        if (criteria.locationMatch)
          _buildMatchChip('Location Match', Icons.location_on, Colors.orange),
        if (criteria.nameSimilarity)
          _buildMatchChip('Name Similarity', Icons.title, Colors.purple),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score > 0.8) return Colors.green;
    if (score > 0.6) return Colors.lightGreen;
    if (score > 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMatchChip(String label, IconData icon, Color color) {
    return Chip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
