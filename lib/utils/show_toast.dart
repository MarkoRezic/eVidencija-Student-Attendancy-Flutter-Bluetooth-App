import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

showToast(String data,
    {required BuildContext context,
    TextAlign? textAlign,
    Color? backgroundColor}) {
  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        data,
        textAlign: textAlign ?? TextAlign.center,
      ),
      backgroundColor: backgroundColor,
    ));
  });
}
