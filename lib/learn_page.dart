 import 'package:flutter/material.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({Key? key}) : super(key: key);

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _viewedSigns = {}; // Track viewed signs
  bool _showQuizPrompt = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Enhanced road signs data with detailed information
  final List<RoadSignCategory> _categories = [
    RoadSignCategory(
      title: 'Regulatory Signs',
      signs: [
        RoadSign(
          name: 'Stop Sign',
          icon: Icons.stop,
          color: Colors.red,
          description: 'Complete stop required at intersection',
          whenUsed: 'At intersections where complete stop is mandatory',
          howToBehave: 'Come to a complete stop, check for traffic and pedestrians, then proceed when safe',
          additionalInfo: 'Octagonal shape with white border. Failure to stop can result in traffic violations.',
          shape: 'Octagon',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        ),
        RoadSign(
          name: 'Yield Sign',
          icon: Icons.change_history,
          color: Colors.red,
          description: 'Give way to other traffic',
          whenUsed: 'At intersections where you must give right-of-way to other traffic',
          howToBehave: 'Slow down, be prepared to stop, and give way to traffic that has the right-of-way',
          additionalInfo: 'Triangular shape with red border and white background. Used where merging traffic must yield.',
          shape: 'Triangle',
          backgroundColor: Colors.white,
          textColor: Colors.red,
        ),
        RoadSign(
          name: 'Speed Limit Sign',
          icon: Icons.speed,
          color: Colors.blue,
          description: 'Maximum speed allowed on this road',
          whenUsed: 'To indicate the maximum legal speed limit for the road section',
          howToBehave: 'Do not exceed the posted speed limit. Adjust speed for road and weather conditions',
          additionalInfo: 'Rectangular white sign with black text. Speed limits may vary by vehicle type.',
          shape: 'Rectangle',
          backgroundColor: Colors.white,
          textColor: Colors.black,
        ),
        RoadSign(
          name: 'No Parking Sign',
          icon: Icons.no_photography,
          color: Colors.blue,
          description: 'Parking prohibited in this area',
          whenUsed: 'In areas where parking is not allowed for safety or traffic flow',
          howToBehave: 'Do not park your vehicle in this area. Find alternative parking locations',
          additionalInfo: 'White rectangular sign with red circle and diagonal line. May show time restrictions.',
          shape: 'Rectangle',
          backgroundColor: Colors.white,
          textColor: Colors.red,
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
          whenUsed: 'Before sharp curves where drivers need to reduce speed',
          howToBehave: 'Reduce speed before entering the curve. Stay in your lane and be prepared for reduced visibility',
          additionalInfo: 'Diamond-shaped yellow sign with black arrow. Arrow direction indicates curve direction.',
          shape: 'Diamond',
          backgroundColor: Colors.yellow[700]!,
          textColor: Colors.black,
        ),
        RoadSign(
          name: 'Pedestrian Crossing',
          icon: Icons.person,
          color: Colors.yellow[700]!,
          description: 'Pedestrian crossing ahead',
          whenUsed: 'Before crosswalks and areas with high pedestrian activity',
          howToBehave: 'Reduce speed, watch for pedestrians, and be prepared to stop for crossing pedestrians',
          additionalInfo: 'Diamond-shaped yellow sign with pedestrian symbol. Crosswalk may not be immediately visible.',
          shape: 'Diamond',
          backgroundColor: Colors.yellow[700]!,
          textColor: Colors.black,
        ),
        RoadSign(
          name: 'School Zone',
          icon: Icons.school,
          color: Colors.yellow[700]!,
          description: 'School zone - reduce speed',
          whenUsed: 'Near schools during school hours',
          howToBehave: 'Reduce speed to posted school zone limit. Watch for children and school buses',
          additionalInfo: 'Pentagon-shaped yellow sign. Speed limits may be lower during school hours.',
          shape: 'Pentagon',
          backgroundColor: Colors.yellow[700]!,
          textColor: Colors.black,
        ),
        RoadSign(
          name: 'Railroad Crossing',
          icon: Icons.train,
          color: Colors.yellow[700]!,
          description: 'Railway crossing ahead',
          whenUsed: 'Before railroad crossings',
          howToBehave: 'Slow down, look and listen for trains. Stop if a train is approaching',
          additionalInfo: 'Circular yellow sign with X symbol and "RR" text. May be accompanied by flashing lights.',
          shape: 'Circle',
          backgroundColor: Colors.yellow[700]!,
          textColor: Colors.black,
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
          whenUsed: 'On interstate highways to show route numbers',
          howToBehave: 'Note the interstate number for navigation purposes',
          additionalInfo: 'Shield-shaped sign with red, white, and blue colors. Indicates major highways.',
          shape: 'Shield',
          backgroundColor: Colors.blue,
          textColor: Colors.white,
        ),
        RoadSign(
          name: 'Route Sign',
          icon: Icons.route,
          color: Colors.green,
          description: 'Route number indicator',
          whenUsed: 'To identify state and federal route numbers',
          howToBehave: 'Use for navigation and route identification',
          additionalInfo: 'Various shapes depending on route type. Green for guidance, different colors for different route types.',
          shape: 'Rectangle',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        ),
        RoadSign(
          name: 'Destination Sign',
          icon: Icons.place,
          color: Colors.green,
          description: 'Direction to destinations',
          whenUsed: 'To provide directional information to cities and destinations',
          howToBehave: 'Follow the arrow direction to reach the indicated destination',
          additionalInfo: 'Green rectangular sign with white text and arrows. Shows distances to destinations.',
          shape: 'Rectangle',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        ),
        RoadSign(
          name: 'Exit Sign',
          icon: Icons.exit_to_app,
          color: Colors.green,
          description: 'Highway exit information',
          whenUsed: 'Before highway exits',
          howToBehave: 'Move to the right lane in advance if you need to take the exit',
          additionalInfo: 'Green sign with white text showing exit number and destinations.',
          shape: 'Rectangle',
          backgroundColor: Colors.green,
          textColor: Colors.white,
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
          final filteredSigns = category.signs
              .where((sign) => sign.name.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
          return RoadSignCategory(title: category.title, signs: filteredSigns);
        })
        .where((category) => category.signs.isNotEmpty)
        .toList();
  }

  void _onSignViewed(String signName) {
    setState(() {
      _viewedSigns.add(signName);
      // Show quiz prompt after viewing 5 signs
      if (_viewedSigns.length >= 5 && !_showQuizPrompt) {
        _showQuizPrompt = true;
        _showQuizDialog();
      }
    });
  }

  void _showQuizDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.quiz, color: Colors.orange[700], size: 28),
              const SizedBox(width: 12),
              const Text('Ready for Quiz?'),
            ],
          ),
          content: Text(
            'Great! You\'ve learned about ${_viewedSigns.length} road signs. '
            'Would you like to take a quiz to test your understanding?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _showQuizPrompt = false;
                });
              },
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startQuiz();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
              ),
              child: const Text('Start Quiz', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _startQuiz() {
    // Get all viewed signs for the quiz
    List<RoadSign> viewedSignsList = [];
    for (var category in _categories) {
      for (var sign in category.signs) {
        if (_viewedSigns.contains(sign.name)) {
          viewedSignsList.add(sign);
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(signs: viewedSignsList),
      ),
    );
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
        actions: [
          if (_viewedSigns.length >= 5)
            IconButton(
              onPressed: _startQuiz,
              icon: Icon(Icons.quiz, color: Colors.orange[700]),
              tooltip: 'Take Quiz',
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_viewedSigns.length} learned',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
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
            child: _filteredCategories.isEmpty
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

  Widget _buildCategorySection(RoadSignCategory category, BuildContext context) {
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
            final displaySigns = category.signs.take(crossAxisCount * 2).toList();

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
    final isViewed = _viewedSigns.contains(sign.name);
    
    return GestureDetector(
      onTap: () => _showSignDetails(sign),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isViewed ? Border.all(color: Colors.green, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
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
            if (isViewed)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSignDetails(RoadSign sign) {
    _onSignViewed(sign.name);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignDetailPage(sign: sign),
      ),
    );
  }

  void _showAllSigns(RoadSignCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllSignsPage(
          category: category,
          onSignViewed: _onSignViewed,
          viewedSigns: _viewedSigns,
        ),
      ),
    );
  }
}

// Enhanced RoadSign model with detailed information
class RoadSign {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final String whenUsed;
  final String howToBehave;
  final String additionalInfo;
  final String shape;
  final Color backgroundColor;
  final Color textColor;

  RoadSign({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.whenUsed,
    required this.howToBehave,
    required this.additionalInfo,
    required this.shape,
    required this.backgroundColor,
    required this.textColor,
  });
}

class RoadSignCategory {
  final String title;
  final List<RoadSign> signs;

  RoadSignCategory({required this.title, required this.signs});
}

// Detailed sign view page
class SignDetailPage extends StatelessWidget {
  final RoadSign sign;

  const SignDetailPage({Key? key, required this.sign}) : super(key: key);

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
          sign.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sign visualization
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: sign.backgroundColor,
                  borderRadius: BorderRadius.circular(
                    sign.shape == 'Circle' ? 60 :
                    sign.shape == 'Octagon' ? 16 : 12
                  ),
                  border: Border.all(
                    color: sign.shape == 'Yield Sign' ? Colors.red : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  sign.icon,
                  color: sign.textColor,
                  size: 60,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sign information cards
            _buildInfoCard(
              'Description',
              sign.description,
              Icons.info_outline,
              Colors.blue,
            ),

            const SizedBox(height: 16),

            _buildInfoCard(
              'When Used',
              sign.whenUsed,
              Icons.location_on,
              Colors.orange,
            ),

            const SizedBox(height: 16),

            _buildInfoCard(
              'How to Behave',
              sign.howToBehave,
              Icons.directions_car,
              Colors.green,
            ),

            const SizedBox(height: 16),

            _buildInfoCard(
              'Additional Information',
              sign.additionalInfo,
              Icons.lightbulb_outline,
              Colors.purple,
            ),

            const SizedBox(height: 16),

            // Sign properties
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Properties',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPropertyItem('Shape', sign.shape),
                      ),
                      Expanded(
                        child: _buildPropertyItem('Background', _getColorName(sign.backgroundColor)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getColorName(Color color) {
    if (color == Colors.red) return 'Red';
    if (color == Colors.white) return 'White';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.yellow[700]) return 'Yellow';
    return 'Other';
  }
}

// Updated AllSignsPage with viewed signs tracking
class AllSignsPage extends StatelessWidget {
  final RoadSignCategory category;
  final Function(String) onSignViewed;
  final Set<String> viewedSigns;

  const AllSignsPage({
    Key? key,
    required this.category,
    required this.onSignViewed,
    required this.viewedSigns,
  }) : super(key: key);

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
      return 3;
    } else if (width > 400) {
      return 2;
    } else {
      return 2;
    }
  }

  Widget _buildSignCard(RoadSign sign, BuildContext context) {
    final isViewed = viewedSigns.contains(sign.name);

    return GestureDetector(
      onTap: () => _showSignDetails(sign, context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isViewed ? Border.all(color: Colors.green, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
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
            if (isViewed)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSignDetails(RoadSign sign, BuildContext context) {
    onSignViewed(sign.name);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignDetailPage(sign: sign),
      ),
    );
  }
}

// Quiz Page
class QuizPage extends StatefulWidget {
  final List<RoadSign> signs;

  const QuizPage({Key? key, required this.signs}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<QuizQuestion> _questions = [];
  String? _selectedAnswer;
  bool _answered = false;
  bool _quizCompleted = false;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    // Shuffle signs and take up to 5 for quiz
    final shuffledSigns = List<RoadSign>.from(widget.signs)..shuffle();
    final quizSigns = shuffledSigns.take(5).toList();

    _questions = quizSigns.map((sign) {
      // Generate different types of questions
      final questionTypes = ['description', 'behavior', 'usage'];
      final questionType = questionTypes[_currentQuestionIndex % questionTypes.length];
      
      return _generateQuestion(sign, questionType);
    }).toList();
  }

  QuizQuestion _generateQuestion(RoadSign sign, String type) {
    List<String> options = [];
    String correctAnswer = '';
    String question = '';

    switch (type) {
      case 'description':
        question = 'What does the "${sign.name}" sign mean?';
        correctAnswer = sign.description;
        break;
      case 'behavior':
        question = 'How should you behave when you see a "${sign.name}"?';
        correctAnswer = sign.howToBehave;
        break;
      case 'usage':
        question = 'When is the "${sign.name}" typically used?';
        correctAnswer = sign.whenUsed;
        break;
    }

    // Get wrong answers from other signs
    final otherSigns = widget.signs.where((s) => s.name != sign.name).toList();
    otherSigns.shuffle();

    options.add(correctAnswer);
    
    // Add 3 wrong options
    for (int i = 0; i < 3 && i < otherSigns.length; i++) {
      String wrongAnswer = '';
      switch (type) {
        case 'description':
          wrongAnswer = otherSigns[i].description;
          break;
        case 'behavior':
          wrongAnswer = otherSigns[i].howToBehave;
          break;
        case 'usage':
          wrongAnswer = otherSigns[i].whenUsed;
          break;
      }
      if (!options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }

    options.shuffle();

    return QuizQuestion(
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      sign: sign,
    );
  }

  void _selectAnswer(String answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      
      if (answer == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });

    // Auto advance after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _answered = false;
      } else {
        _quizCompleted = true;
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _answered = false;
      _quizCompleted = false;
    });
    _generateQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return _buildResultsPage();
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.black),
        ),
        title: Text(
          'Quiz ${_currentQuestionIndex + 1}/${_questions.length}',
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
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),

            const SizedBox(height: 24),

            // Score display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Score: $_score/${_questions.length}',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Sign visualization
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: currentQuestion.sign.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                currentQuestion.sign.icon,
                color: currentQuestion.sign.textColor,
                size: 50,
              ),
            ),

            const SizedBox(height: 24),

            // Question
            Text(
              currentQuestion.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final option = currentQuestion.options[index];
                  final isSelected = _selectedAnswer == option;
                  final isCorrect = option == currentQuestion.correctAnswer;
                  
                  Color? cardColor;
                  Color? textColor;
                  IconData? icon;

                  if (_answered) {
                    if (isCorrect) {
                      cardColor = Colors.green[100];
                      textColor = Colors.green[700];
                      icon = Icons.check_circle;
                    } else if (isSelected && !isCorrect) {
                      cardColor = Colors.red[100];
                      textColor = Colors.red[700];
                      icon = Icons.cancel;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _selectAnswer(option),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor ?? Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor ?? Colors.black87,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (icon != null)
                              Icon(icon, color: textColor, size: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsPage() {
    final percentage = (_score / _questions.length * 100).round();
    String resultMessage = '';
    Color resultColor = Colors.blue;
    IconData resultIcon = Icons.school;

    if (percentage >= 80) {
      resultMessage = 'Excellent! You have a great understanding of road signs.';
      resultColor = Colors.green;
      resultIcon = Icons.star;
    } else if (percentage >= 60) {
      resultMessage = 'Good job! You\'re on the right track.';
      resultColor = Colors.orange;
      resultIcon = Icons.thumb_up;
    } else {
      resultMessage = 'Keep studying! Practice makes perfect.';
      resultColor = Colors.red;
      resultIcon = Icons.school;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.black),
        ),
        title: const Text(
          'Quiz Results',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              resultIcon,
              size: 100,
              color: resultColor,
            ),

            const SizedBox(height: 24),

            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: resultColor,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'You scored $_score out of ${_questions.length}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
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
              child: Text(
                resultMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _restartQuiz,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF1A237E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        color: Color(0xFF1A237E),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue Learning',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final RoadSign sign;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.sign,
  });
}