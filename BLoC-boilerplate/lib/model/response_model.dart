class ResponseModel {
  String? status;
  bool isSuccess;
  int? statusCode;
  Object? data;
  String? error;

  ResponseModel({
    this.status,
    this.statusCode,
    this.isSuccess = false,
    this.data,
    this.error,
  });

  ResponseModel copyWith({
    String? status,
    int? statusCode,
    Object? data,
    String? error,
    bool? isSuccess,
  }) =>
      ResponseModel(
        status: status ?? this.status,
        statusCode: statusCode ?? this.statusCode,
        data: data ?? this.data,
        isSuccess: isSuccess ?? this.isSuccess,
        error: error ?? this.error,
      );
}
