import 'package:flutter/material.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({Key? key}) : super(key: key);

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Road signs data
  final List<RoadSignCategory> _categories = [
    RoadSignCategory(
      title: 'Regulatory Signs',
      signs: [
        RoadSign(
          name: 'Stop Sign',
          icon: Icons.stop,
          color: Colors.red,
          description: 'Complete stop required',
        ),
        RoadSign(
          name: 'Yield Sign',
          icon: Icons.change_history,
          color: Colors.red,
          description: 'Give way to other traffic',
        ),
        RoadSign(
          name: 'Speed Limit Sign',
          icon: Icons.speed,
          color: Colors.blue,
          description: 'Maximum speed allowed',
        ),
        RoadSign(
          name: 'No Parking Sign',
          icon: Icons.no_photography,
          color: Colors.blue,
          description: 'Parking prohibited',
        ),
      ],
    ),
    RoadSignCategory(
      title: 'Warning Signs',
      signs: [
        RoadSign(
          name: 'Curve Ahead',
          icon: Icons.turn_right,
          color: Colors.yellow[700]!,
          description: 'Sharp curve approaching',
        ),
        RoadSign(
          name: 'Pedestrian Crossing',
          icon: Icons.person,
          color: Colors.yellow[700]!,
          description: 'Pedestrian crossing ahead',
        ),
        RoadSign(
          name: 'School Zone',
          icon: Icons.school,
          color: Colors.yellow[700]!,
          description: 'School zone - reduce speed',
        ),
        RoadSign(
          name: 'Railroad Crossing',
          icon: Icons.train,
          color: Colors.yellow[700]!,
          description: 'Railway crossing ahead',
        ),
      ],
    ),
    RoadSignCategory(
      title: 'Guide Signs',
      signs: [
        RoadSign(
          name: 'Interstate Sign',
          icon: Icons.directions,
          color: Colors.blue,
          description: 'Interstate highway marker',
        ),
        RoadSign(
          name: 'Route Sign',
          icon: Icons.route,
          color: Colors.green,
          description: 'Route number indicator',
        ),
        RoadSign(
          name: 'Destination Sign',
          icon: Icons.place,
          color: Colors.green,
          description: 'Direction to destinations',
        ),
        RoadSign(
          name: 'Exit Sign',
          icon: Icons.exit_to_app,
          color: Colors.green,
          description: 'Highway exit information',
        ),
      ],
    ),
  ];

  List<RoadSignCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) {
      return _categories;
    }

    return _categories
        .map((category) {
          final filteredSigns =
              category.signs
                  .where(
                    (sign) => sign.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
                  )
                  .toList();

          return RoadSignCategory(title: category.title, signs: filteredSigns);
        })
        .where((category) => category.signs.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Road Signs',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search road signs...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Content
          Expanded(
            child:
                _filteredCategories.isEmpty
                    ? const Center(
                      child: Text(
                        'No road signs found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = _filteredCategories[index];
                        return _buildCategorySection(category, context);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    RoadSignCategory category,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  _showAllSigns(category);
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF1A237E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Responsive Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
            final displaySigns =
                category.signs.take(crossAxisCount * 2).toList();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: displaySigns.length,
              itemBuilder: (context, index) {
                return _buildSignCard(displaySigns[index]);
              },
            );
          },
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 600) {
      return 4; // Tablet/Desktop
    } else if (width > 400) {
      return 2; // Large phone
    } else {
      return 2; // Small phone
    }
  }

  Widget _buildSignCard(RoadSign sign) {
    return GestureDetector(
      onTap: () => _showSignDetails(sign),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: sign.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(sign.icon, color: sign.color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                sign.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignDetails(RoadSign sign) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: sign.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(sign.icon, color: sign.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(sign.name, style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
          content: Text(sign.description, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAllSigns(RoadSignCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllSignsPage(category: category)),
    );
  }
}

// Data models
class RoadSignCategory {
  final String title;
  final List<RoadSign> signs;

  RoadSignCategory({required this.title, required this.signs});
}

class RoadSign {
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  RoadSign({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

// Page to show all signs in a category
class AllSignsPage extends StatelessWidget {
  final RoadSignCategory category;

  const AllSignsPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          category.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: category.signs.length,
              itemBuilder: (context, index) {
                final sign = category.signs[index];
                return _buildSignCard(sign, context);
              },
            );
          },
        ),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 600) {
      return 3; // Tablet/Desktop
    } else if (width > 400) {
      return 2; // Large phone
    } else {
      return 2; // Small phone
    }
  }

  Widget _buildSignCard(RoadSign sign, BuildContext context) {
    return GestureDetector(
      onTap: () => _showSignDetails(sign, context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: sign.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(sign.icon, color: sign.color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                sign.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignDetails(RoadSign sign, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: sign.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(sign.icon, color: sign.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(sign.name, style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
          content: Text(sign.description, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
