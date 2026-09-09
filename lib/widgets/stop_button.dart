import 'package:flutter/material.dart';

class StopButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StopButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      width: 180,
      height: 75,

      child: ElevatedButton(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFFC93333),

          foregroundColor:
              Colors.white,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              22,
            ),
          ),
        ),

        onPressed: onPressed,

        child: const Text(
          'STOP',
          style: TextStyle(
            fontSize: 24,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
    );
  }
}