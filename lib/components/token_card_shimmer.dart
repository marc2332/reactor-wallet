import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TokenCardWithShimmer extends StatelessWidget {
  const TokenCardWithShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(150, 0, 0, 0),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
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
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Shimmer.fromColors(
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
                ),
              ],
            ),
          ),
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 10,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(150, 0, 0, 0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
