import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class FiatBalance extends StatelessWidget {
  final String usdBalance;
  final bool isReady;

  const FiatBalance({Key? key, required this.usdBalance, required this.isReady}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isReady) {
      return Text('\$$usdBalance',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 33,
            ),
          ),
          textAlign: TextAlign.left);
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 150,
            height: 36,
            decoration: BoxDecoration(
              color: const Color.fromARGB(150, 0, 0, 0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      );
    }
  }
}
