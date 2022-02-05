import 'package:flutter/material.dart';
import 'package:reactor_wallet/utils/theme.dart';

/*
 * Card with ripple effect
 */
class ClickableCard extends StatelessWidget {
  final Widget child;
  Color? color = null;
  final void Function() onTap;

  ClickableCard({Key? key, required this.child, required this.onTap, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        splashColor: Theme.of(context).hoverColor,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
