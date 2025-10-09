import 'package:flutter/material.dart';

class ProfileSubSectionTile extends StatelessWidget {
  final String? title, subTitle;
  final IconData? leading, trailing;
  final bool? isCompleted;
  final Color? leadingIconColor;
  final double iconSize;
  const ProfileSubSectionTile({
    super.key,
    this.title,
    this.subTitle,
    this.leading,
    this.trailing,
    this.isCompleted,
    this.leadingIconColor,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(155),
            blurRadius: 6.0,
            offset: Offset(1, 1),
          ),
        ],
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              leading,
              color: leadingIconColor ?? Colors.grey,
              size: iconSize,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title ?? "", style: TextStyle(fontSize: 18)),
              Text(subTitle ?? "", overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }
}
