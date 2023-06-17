import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

showToast(String data, {required BuildContext context, TextAlign? textAlign}) {
  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      data,
      textAlign: textAlign ?? TextAlign.center,
    )));
  });
}
