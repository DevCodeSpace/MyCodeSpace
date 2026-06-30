class ResumeResultModel {
  final String name;
  final int score;
  final List strengths;
  final List weaknesses;
  final List questions;

  ResumeResultModel({required this.name, required this.score, required this.strengths, required this.weaknesses, required this.questions});

  factory ResumeResultModel.fromJson(Map<String, dynamic> json) {
    return ResumeResultModel(
      name: json['name'] ?? '',
      score: json['score'] ?? 0,
      strengths: json['strengths'] ?? [],
      weaknesses: json['weaknesses'] ?? [],
      questions: json['questions'] ?? [],
    );
  }
}
