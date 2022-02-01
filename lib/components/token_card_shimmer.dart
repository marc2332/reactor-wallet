import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TokenCardWithShimmer extends StatelessWidget {
  const TokenCardWithShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(150, 0, 0, 0),
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(150, 0, 0, 0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(150, 0, 0, 0),
                      borderRadius: BorderRadius.circular(3),
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
                  color: Color.fromARGB(150, 0, 0, 0),
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
