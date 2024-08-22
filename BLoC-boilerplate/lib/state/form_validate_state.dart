class FormValidateState {
  bool isLoading;
  bool isValid;
  bool isShowMsg;
  String message;
  MsgStatus msgStatus;

  FormValidateState({
    this.isLoading = false,
    this.isValid = true,
    this.isShowMsg = false,
    this.message = "",
    this.msgStatus = MsgStatus.error,
  });

  FormValidateState copyWith(
          {bool? isLoading,
          bool? isValid,
          bool? isShowMsg,
          String? message,
          MsgStatus? msgStatus}) =>
      FormValidateState(
        isLoading: isLoading ?? this.isLoading,
        isValid: isValid ?? this.isValid,
        message: message ?? this.message,
        msgStatus: msgStatus ?? this.msgStatus,
        isShowMsg: isShowMsg ?? this.isShowMsg,
      );
}

enum MsgStatus { error, success, warning }
