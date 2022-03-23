import 'package:flutter/material.dart';
import 'package:reactor_wallet/components/token_card.dart';
import 'package:shimmer/shimmer.dart';

class TokenCardWithShimmer extends StatelessWidget {
  const TokenCardWithShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TokenCard(
      image:  Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(150, 0, 0, 0),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
          ),
      title: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 65,
          height: 17,
          decoration: BoxDecoration(
            color: const Color.fromARGB(150, 0, 0, 0),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
      subtitle: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 20,
          height: 17,
          decoration: BoxDecoration(
            color: const Color.fromARGB(150, 0, 0, 0),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      tail: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 30,
          height: 20,
          decoration: BoxDecoration(
            color: const Color.fromARGB(150, 0, 0, 0),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
