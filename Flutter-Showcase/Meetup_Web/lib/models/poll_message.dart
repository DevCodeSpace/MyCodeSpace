class PollMessage {
  final String pollId;
  final String question;
  final List<String> options;
  final String sender;
  final DateTime timestamp;
  final List<int> votes;
  int localVotedIndex;

  PollMessage({
    required this.pollId,
    required this.question,
    required this.options,
    required this.sender,
    DateTime? timestamp,
    List<int>? votes,
    this.localVotedIndex = -1,
  }) : timestamp = timestamp ?? DateTime.now(),
       votes = votes ?? List<int>.filled(options.length, 0);

  /// Register a vote for [optionIndex] and record it locally.
  void vote(int optionIndex) {
    if (optionIndex >= 0 && optionIndex < votes.length) {
      // Undo previous vote
      if (localVotedIndex >= 0 && localVotedIndex < votes.length) {
        votes[localVotedIndex] = (votes[localVotedIndex] - 1).clamp(0, 999);
      }
      votes[optionIndex]++;
      localVotedIndex = optionIndex;
    }
  }

  int get totalVotes => votes.fold(0, (sum, v) => sum + v);

  Map<String, dynamic> toJson() => {'pollId': pollId, 'question': question, 'options': options, 'sender': sender, 'votes': votes};

  factory PollMessage.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final vts = (json['votes'] as List<dynamic>? ?? []).map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).toList();
    return PollMessage(
      pollId: json['pollId'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: opts,
      sender: json['sender'] as String? ?? 'Unknown',
      votes: vts.length == opts.length ? vts : List<int>.filled(opts.length, 0),
    );
  }
}
