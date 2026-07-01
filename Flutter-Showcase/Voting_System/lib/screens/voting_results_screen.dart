import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VotingResultsScreen extends StatefulWidget {
  const VotingResultsScreen({super.key});

  @override
  State<VotingResultsScreen> createState() => _VotingResultsScreenState();
}

class _VotingResultsScreenState extends State<VotingResultsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _results = [];
  List<Map<String, dynamic>> _allUsers = [];
  int _submittedCount = 0;

  static const skyBlue = Color(0xFF4FC3F7);

  final List<String> _questions = [
    'Rapid Delivery Pro Award - the one who completes tasks with lightning speed and flawless results always delivering before the deadline!',
    'Supportive Hand Award - the teammate who’s always ready to help others making everyone’s work smoother with their support and positivity.',
    'Unsung Hero Award - the silent contributor who may not always be in the spotlight but plays a major role in every success.',
    'Innovation Ninja Award - the creative mind who brings fresh ideas, smart solutions, and out-of-the-box thinking to the table.',
    'Prime Player Award -  the one who uplifts the team spirit, contributes in every phase, and makes collaboration smooth and fun.',
  ];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      // Load all users
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('userJKMaster')
          .get();

      _allUsers = usersSnapshot.docs
          .map(
            (doc) => {
              'uid': doc.id,
              'fullName': doc.data()['fullName'] ?? 'Unknown',
              'email': doc.data()['email'] ?? '',
            },
          )
          .toList();

      // Load all votes
      final votesSnapshot = await FirebaseFirestore.instance
          .collection('jkTeamvotes')
          .get();

      _submittedCount = votesSnapshot.docs.length;

      // Process votes for each question
      _results = [];

      for (int i = 0; i < _questions.length; i++) {
        String questionKey = 'question${i + 1}';
        Map<String, int> voteCounts = {};

        // Count votes from all users
        for (var doc in votesSnapshot.docs) {
          final data = doc.data();
          final votes = data['votes'] as Map<String, dynamic>?;

          if (votes != null && votes.containsKey(questionKey)) {
            final selectedUsers = List<String>.from(votes[questionKey]);

            for (var userId in selectedUsers) {
              voteCounts[userId] = (voteCounts[userId] ?? 0) + 1;
            }
          }
        }

        // Sort by vote count
        final sortedVotes = voteCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final totalVotes = voteCounts.values.fold(
          0,
          (sum, count) => sum + count,
        );

        _results.add({
          'questionText': _questions[i],
          'voteCounts': sortedVotes,
          'totalVotes': totalVotes,
        });
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading results: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getUserName(String uid) {
    final user = _allUsers.firstWhere(
      (u) => u['uid'] == uid,
      orElse: () => {'fullName': 'Unknown'},
    );
    return user['fullName'];
  }

  Future<List<Map<String, dynamic>>> _getUsersWithSubmissionStatus() async {
    try {
      final votesSnapshot = await FirebaseFirestore.instance
          .collection('jkTeamvotes')
          .get();

      final submittedUserIds = votesSnapshot.docs.map((doc) => doc.id).toSet();

      return _allUsers.map((user) {
        return {...user, 'isSubmit': submittedUserIds.contains(user['uid'])};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF263238),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: skyBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Voting Results',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(skyBlue),
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Submission Status Section
                Expanded(child: _buildUserStatusSection()),

                // Divider (vertical)
                Container(width: 1, color: Colors.grey.shade200),

                // Voting Results Section
                Expanded(child: _buildVotingResultsSection()),
              ],
            ),
    );
  }

  Widget _buildUserStatusSection() {
    final totalCount = _allUsers.length;

    return Container(
      padding: const EdgeInsets.all(24),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getUsersWithSubmissionStatus(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(skyBlue),
              ),
            );
          }

          final usersWithStatus = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Submission Status',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263238),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: skyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: skyBlue),
                      ),
                      child: Text(
                        '$_submittedCount/$totalCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: skyBlue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: usersWithStatus.length,
                  itemBuilder: (context, index) {
                    final user = usersWithStatus[index];
                    final hasSubmitted = user['isSubmit'] as bool;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: hasSubmitted
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            hasSubmitted
                                ? Icons.check_circle_rounded
                                : Icons.pending_outlined,
                            color: hasSubmitted
                                ? Colors.green.shade400
                                : Colors.grey.shade400,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          user['fullName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          user['email'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: hasSubmitted
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            hasSubmitted ? 'Submitted' : 'Pending',
                            style: TextStyle(
                              color: hasSubmitted
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVotingResultsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voting Results',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                return _buildQuestionResultCard(result, index + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionResultCard(
    Map<String, dynamic> result,
    int questionNumber,
  ) {
    final voteCounts = result['voteCounts'] as List<MapEntry<String, int>>;
    final totalVotes = result['totalVotes'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          childrenPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: skyBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$questionNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          title: Text(
            result['questionText'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF263238),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Total Votes: $totalVotes',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          children: [
            const SizedBox(height: 8),
            if (voteCounts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No votes yet',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: voteCounts.length,
                itemBuilder: (context, idx) {
                  final entry = voteCounts[idx];
                  final percentage = totalVotes > 0
                      ? (entry.value / totalVotes * 100).toStringAsFixed(1)
                      : '0.0';

                  Color barColor;
                  if (idx == 0) {
                    barColor = Colors.green.shade400;
                  } else if (idx == 1) {
                    barColor = skyBlue;
                  } else if (idx == 2) {
                    barColor = Colors.orange.shade400;
                  } else {
                    barColor = Colors.grey.shade400;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (idx < 3)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: barColor.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${idx + 1}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: barColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      _getUserName(entry.key),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Color(0xFF263238),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${entry.value} ($percentage%)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: barColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: totalVotes > 0
                                ? entry.value / totalVotes
                                : 0,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
