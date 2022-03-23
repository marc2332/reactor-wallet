import 'package:flutter/material.dart';

class TokenCard extends StatelessWidget {
  final Widget title;
  final Widget subtitle;
  final Widget image;
  final Widget tail;

  const TokenCard(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.image,
      required this.tail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        splashColor: Theme.of(context).hoverColor,
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              SizedBox(
                width: 70,
                height: 40,
                child: Padding(padding: const EdgeInsets.only(left: 10, right: 20), child: image),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    subtitle,
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [Padding(padding: const EdgeInsets.only(right: 10), child: tail)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
