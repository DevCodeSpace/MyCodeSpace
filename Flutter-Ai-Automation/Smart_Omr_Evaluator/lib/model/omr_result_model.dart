class OMRResultResponse {
  String? name;
  String? rollNumber;
  int? marks;
  int? totalQuestions;
  String? accuracy;

  OMRResultResponse({this.name, this.rollNumber, this.marks, this.totalQuestions, this.accuracy});

  OMRResultResponse.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    rollNumber = json['rollNumber'];
    marks = json['marks'];
    totalQuestions = json['totalQuestions'];
    accuracy = json['accuracy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['rollNumber'] = rollNumber;
    data['marks'] = marks;
    data['totalQuestions'] = totalQuestions;
    data['accuracy'] = accuracy;
    return data;
  }
}
