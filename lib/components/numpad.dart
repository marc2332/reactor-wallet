import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RoundedButton extends StatelessWidget {
  final void Function(String) onPressed;
  final String value;
  final IconData? icon;

  const RoundedButton({Key? key, required this.onPressed, required this.value, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        height: 50,
        width: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: () => onPressed(value),
          child: icon != null
              ? Icon(
                  icon,
                  size: 17,
                )
              : Text(value.toString()),
        ),
      ),
    );
  }
}

class Numpad extends HookConsumerWidget {
  final void Function(String) onPressed;

  const Numpad({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              RoundedButton(
                value: "1",
                onPressed: onPressed,
              ),
              RoundedButton(
                value: "2",
                onPressed: onPressed,
              ),
              RoundedButton(
                value: "3",
                onPressed: onPressed,
              )
            ],
          ),
          Row(
            children: [
              RoundedButton(
                value: "4",
                onPressed: onPressed,
              ),
              RoundedButton(
                value: "5",
                onPressed: onPressed,
              ),
              RoundedButton(
                value: "6",
                onPressed: onPressed,
              )
            ],
          ),
          Row(
            children: [
              RoundedButton(
                value: "7",
                onPressed: onPressed,
              ),
              RoundedButton(
                value: "8",
                onPressed: onPressed,
              ),
              RoundedButton(
                value: "9",
                onPressed: onPressed,
              )
            ],
          ),
          Row(
            children: [
              RoundedButton(
                value: ".",
                onPressed: onPressed,
              ),
              RoundedButton(
                value: "0",
                onPressed: onPressed,
              ),
              RoundedButton(
                value: "D",
                icon: Icons.backspace_outlined,
                onPressed: onPressed,
              ),
            ],
          )
        ],
      ),
    );
  }
}
