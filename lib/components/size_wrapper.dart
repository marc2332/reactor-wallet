import 'package:flutter/material.dart';

class ResponsiveSizer extends StatelessWidget {
  final Widget child;
  final double triggerWidth;

  const ResponsiveSizer({Key? key, required this.child, this.triggerWidth = 600}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (screenSize.width > triggerWidth) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 600, child: child),
        ],
      );
    } else {
      return SizedBox(width: 600, child: child);
    }
  }
}
