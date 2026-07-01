class AccountModel {
  final String account;
  final String secret;

  AccountModel({required this.account, required this.secret});

  Map<String, dynamic> toJson() {
    return {'account': account, 'secret': secret};
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(account: json['account'], secret: json['secret']);
  }
}
