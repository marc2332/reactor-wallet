import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class SolBalance extends StatelessWidget {
  final String solBalance;
  final bool isReady;

  const SolBalance({Key? key, required this.solBalance, required this.isReady}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isReady) {
      return Row(
        children: [
          Text(
            solBalance,
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '  SOL',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 110,
            height: 30,
            decoration: BoxDecoration(
              color: const Color.fromARGB(150, 0, 0, 0),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      );
    }
  }
}
