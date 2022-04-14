import 'package:flutter/material.dart';

class StretchedButton extends StatelessWidget {
  final Function()? onPressed;
  final Widget child;

  const StretchedButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 50,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
