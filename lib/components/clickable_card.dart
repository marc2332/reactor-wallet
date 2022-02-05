import 'package:flutter/material.dart';
import 'package:reactor_wallet/utils/theme.dart';

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
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        splashColor: Theme.of(context).hoverColor,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
