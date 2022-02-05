import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TransactionCardWithShimmer extends StatelessWidget {
  const TransactionCardWithShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 35,
              height: 20,
              decoration: BoxDecoration(
                color: const Color.fromARGB(150, 0, 0, 0),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(150, 0, 0, 0),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 100,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(150, 0, 0, 0),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
