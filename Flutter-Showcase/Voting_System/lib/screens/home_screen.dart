import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voting_sysyem/screens/voting_results_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- Constants and State Variables (NO CHANGE IN FUNCTIONALITY) ---
  final List<Map<String, dynamic>> _questions = [
    {
      'question':
          'Rapid Delivery Pro Award \n(the one who completes tasks with lightning speed and flawless results always delivering before the deadline!)',
      'selectedUsers': <String>[],
    },
    {
      'question':
          'Supportive Hand Award \n(the teammate who’s always ready to help others making everyone’s work smoother with their support and positivity.)',
      'selectedUsers': <String>[],
    },
    {
      'question':
          'Unsung Hero Award \n (the silent contributor who may not always be in the spotlight but plays a major role in every success.)',
      'selectedUsers': <String>[],
    },
    {
      'question':
          'Innovation Ninja Award \n (the creative mind who brings fresh ideas, smart solutions, and out-of-the-box thinking to the table.)',
      'selectedUsers': <String>[],
    },
    {
      'question':
          'Prime Player Award \n (the one who uplifts the team spirit, contributes in every phase, and makes collaboration smooth and fun.)',
      'selectedUsers': <String>[],
    },
  ];

  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasSubmitted = false;
  String? _currentUserUid;
  int? _currentUserType;

  // Refined Color: Lightened the primary color slightly and added a dark text color.
  static const primaryColor = Color(
    0xFF00B0FF,
  ); // A slightly more vibrant sky blue
  static const darkTextColor = Color(0xFF1A237E); // Deep Indigo for contrast

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // --- FUNCTIONALITY METHODS (NO CHANGE) ---
  Future<void> _loadUsers() async {
    /* ... (Your existing logic) ... */
    try {
      _currentUserUid = FirebaseAuth.instance.currentUser?.uid;

      if (_currentUserUid != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('userJKMaster')
            .doc(_currentUserUid)
            .get();

        _currentUserType = userDoc.data()?['userType'];

        final voteDoc = await FirebaseFirestore.instance
            .collection('jkTeamvotes')
            .doc(_currentUserUid)
            .get();

        _hasSubmitted = voteDoc.exists;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('userJKMaster')
          .get();

      _allUsers = snapshot.docs
          .where(
            (doc) => doc.id != _currentUserUid && doc.data()['userType'] == 1,
          )
          .map(
            (doc) => {
              'uid': doc.id,
              'fullName': doc.data()['fullName'] ?? 'Unknown',
              'email': doc.data()['email'] ?? '',
            },
          )
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Helper method to get all selected users across all questions except current question
  Set<String> _getSelectedUsersExceptCurrent(int currentQuestionIndex) {
    Set<String> selectedUsers = {};
    for (int i = 0; i < _questions.length; i++) {
      if (i != currentQuestionIndex) {
        final users = _questions[i]['selectedUsers'] as List<String>;
        selectedUsers.addAll(users);
      }
    }
    return selectedUsers;
  }

  bool _isFormComplete() {
    return _questions.every((q) => q['selectedUsers'].length == 2);
  }

  Future<void> _submitVotes() async {
    /* ... (Your existing logic) ... */
    if (!_isFormComplete()) return;

    setState(() => _isSubmitting = true);

    try {
      Map<String, dynamic> votesMap = {};

      for (int i = 0; i < _questions.length; i++) {
        votesMap['question${i + 1}'] = _questions[i]['selectedUsers'];
      }

      await FirebaseFirestore.instance
          .collection('jkTeamvotes')
          .doc(_currentUserUid)
          .set({
            'userId': _currentUserUid,
            'votes': votesMap,
            'submittedAt': FieldValue.serverTimestamp(),
          });

      setState(() {
        _hasSubmitted = true;
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Votes submitted successfully!'),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting votes: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _navigateToResults() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VotingResultsScreen()),
    );
  }

  // --- WIDGET BUILDER METHODS (DESIGN REFINEMENT) ---

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // Changed background to a very light, almost white grey for subtle depth
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        // Removed elevation, using a subtle shadow for a modern flat look
        elevation: 0,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        foregroundColor: darkTextColor, // Used new dark text color
        // Added a subtle shadow below the AppBar
        shadowColor: Colors.black.withOpacity(0.08),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primaryColor, // Used new primary color
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.how_to_vote_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Voting System',
              // Increased weight slightly for prominence
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ],
        ),
        actions: [
          if (_currentUserType == 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _navigateToResults,
                icon: const Icon(Icons.bar_chart_rounded),
                label: const Text('Results'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor, // Used new primary color
                  // Removed padding/elevation for a flatter look
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : _hasSubmitted
          ? _buildAlreadySubmittedView()
          : _buildVotingForm(user),
    );
  }

  Widget _buildAlreadySubmittedView() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Used a subtle, modern BoxShadow instead of a border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 60,
                color: Colors.green.shade500, // Slightly deeper green
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Thank You!',
              style: TextStyle(
                fontSize: 32, // Slightly larger for impact
                fontWeight: FontWeight.bold,
                color: darkTextColor, // Used dark text color
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You have already submitted your votes.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingForm(User? user) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            // Used a subtle border bottom
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Logged in as: ${user?.email ?? "Unknown"}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                height: 50,
                child: ElevatedButton(
                  onPressed: _isFormComplete() && !_isSubmitting
                      ? _submitVotes
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, // Used new primary color
                    foregroundColor: Colors.white,
                    // Subtle elevation
                    elevation: 1,
                    shadowColor: primaryColor.withOpacity(0.4),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      // Slightly smaller radius for a cleaner look
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.send_rounded,
                              size: 18,
                            ), // Changed icon
                            const SizedBox(width: 8),
                            Text(
                              _isFormComplete()
                                  ? 'Submit Votes'
                                  : 'Select 2 users for all questions', // More concise text
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              return _buildQuestionCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = _questions[index];
    final selectedUsers = question['selectedUsers'] as List<String>;
    final isComplete =
        selectedUsers.length == 2 &&
        selectedUsers[0].isNotEmpty &&
        selectedUsers[1].isNotEmpty;

    // Get users selected in OTHER questions
    final usersSelectedElsewhere = _getSelectedUsersExceptCurrent(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Slightly smaller radius
        // Used a subtle, modern BoxShadow instead of a border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        // Added a conditional border to highlight completion status
        border: Border.all(
          color: isComplete ? Colors.green.shade300 : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8), // Smaller radius
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700, // Slightly bolder number
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    question['question'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700, // Bolder question text
                      color: darkTextColor, // Darker text for prominence
                    ),
                  ),
                ),
                if (isComplete)
                  Icon(
                    Icons.check_circle_rounded, // Slightly rounded icon
                    color: Colors.green.shade500,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 24), // Increased vertical space
            Text(
              'Select 2 users:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700, // Slightly darker grey
                fontWeight: FontWeight.w600, // Semibold for emphasis
              ),
            ),
            const SizedBox(height: 16),

            // FIRST DROPDOWN
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'First Choice (1st Rank)', // More descriptive label
                labelStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(
                  Icons.star_outline_rounded,
                  color: primaryColor,
                  size: 20,
                ), // Star icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              initialValue:
                  _allUsers.any(
                    (u) =>
                        u['uid'] ==
                        (selectedUsers.isNotEmpty ? selectedUsers[0] : null),
                  )
                  ? selectedUsers[0]
                  : null,

              items: _allUsers
                  .map((user) {
                    final uid = user['uid'] as String;
                    // Show user if:
                    // 1. Not selected in current question (or is the first choice), AND
                    // 2. Not selected in any other question
                    final isSelectedInCurrent = selectedUsers.contains(uid);
                    final isSelectedElsewhere = usersSelectedElsewhere.contains(
                      uid,
                    );

                    final isAvailable =
                        (!isSelectedInCurrent ||
                            (selectedUsers.isNotEmpty &&
                                selectedUsers[0] == uid)) &&
                        !isSelectedElsewhere;

                    if (!isAvailable) return null;

                    return DropdownMenuItem<String>(
                      value: uid,
                      child: Text(user['fullName']),
                    );
                  })
                  .whereType<DropdownMenuItem<String>>()
                  .toList(),
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    if (selectedUsers.isEmpty) {
                      selectedUsers.add(value);
                    } else if (selectedUsers.length == 1) {
                      selectedUsers[0] = value;
                    } else {
                      selectedUsers[0] = value;
                    }
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // SECOND DROPDOWN
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Second Choice (2nd Rank)', // More descriptive label
                labelStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(
                  Icons.star_half_rounded,
                  color: primaryColor,
                  size: 20,
                ), // Star icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              initialValue:
                  _allUsers.any(
                    (u) =>
                        u['uid'] ==
                        (selectedUsers.length > 1 ? selectedUsers[1] : null),
                  )
                  ? selectedUsers.length > 1
                        ? selectedUsers[1]
                        : null
                  : null,

              items: _allUsers
                  .map((user) {
                    final uid = user['uid'] as String;
                    // Show user if:
                    // 1. Not selected in current question (or is the second choice), AND
                    // 2. Not selected in any other question
                    final isSelectedInCurrent = selectedUsers.contains(uid);
                    final isSelectedElsewhere = usersSelectedElsewhere.contains(
                      uid,
                    );

                    final isAvailable =
                        (!isSelectedInCurrent ||
                            (selectedUsers.length > 1 &&
                                selectedUsers[1] == uid)) &&
                        !isSelectedElsewhere;

                    if (!isAvailable) return null;

                    return DropdownMenuItem<String>(
                      value: uid,
                      child: Text(user['fullName']),
                    );
                  })
                  .whereType<DropdownMenuItem<String>>()
                  .toList(),
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    if (selectedUsers.isEmpty) {
                      // Add placeholder for first choice, then add second choice
                      selectedUsers.add('');
                      selectedUsers.add(value);
                    } else if (selectedUsers.length == 1) {
                      // If only first is selected, append second
                      selectedUsers.add(value);
                    } else {
                      // Replace second choice
                      selectedUsers[1] = value;
                    }
                  }
                });
              },
            ),

            if (isComplete)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Selection Complete',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
