import 'package:flutter/material.dart';

/*
 * Card with ripple effect
 */
class ClickableCard extends StatelessWidget {
  final Widget child;

  final void Function() onTap;

  const ClickableCard({Key? key, required this.child, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        splashColor: Theme.of(context).hoverColor,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
