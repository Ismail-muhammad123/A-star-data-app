import 'package:flutter/material.dart';

class CustomerWidget extends StatelessWidget {
  final Function() onPressed;
  final String title;
  final Color? color;
  final double? minWidth;
  final double? height;
  const CustomerWidget({
    super.key,
    required this.title,
    required this.onPressed,
    this.color = Colors.red,
    this.minWidth = 200,
    this.height = 45,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: color ?? Colors.red,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      height: height ?? 45,
      minWidth: minWidth ?? 200,
      onPressed: onPressed,
      child: Text(title, style: TextStyle(color: Colors.white, fontSize: 20)),
    );
  }
}
