import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar_helper.dart';
showErrorMessage(context, String? message) {
  Future.delayed(Duration(milliseconds: 5), () {
    if (message != null && message.isNotEmpty) {
      FlushbarHelper.createError(
        message: message,
        title: 'error',
        duration: Duration(seconds: 3),
      )..show(context);
    }
  });

  return SizedBox.shrink();
}