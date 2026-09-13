import 'package:flutter/material.dart';

class SteeringSlider extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final VoidCallback? onReleased;
  final int initialValue;

  const SteeringSlider({
    super.key,
    required this.onChanged,
    this.onReleased,
    this.initialValue = 60,
  });

  @override
  State<SteeringSlider> createState() => _SteeringSliderState();
}

class _SteeringSliderState extends State<SteeringSlider> {
  static const int minAngle = 30;
  static const int maxAngle = 90;
  static const int centerAngle = 60;

  // Kenarlara neredeyse sıfır yanaşması için kenar boşluğu (margin)
  static const double horizontalMargin = 8.0;

  late num value;

  @override
  void initState() {
    super.initState();

    value = widget.initialValue
        .toDouble()
        .clamp(
          minAngle.toDouble(),
          maxAngle.toDouble(),
        );
  }

  void updateFromPosition(
    Offset position,
    BoxConstraints constraints,
  ) {
    final width = constraints.maxWidth;
    if (width <= 0) return;

    // Rayın kullanılabilir net genişliği
    final usableWidth = width - (horizontalMargin * 2);

    // Dokunulan X noktasını ray sınırlarına clamp ediyoruz
    final x = (position.dx - horizontalMargin).clamp(0.0, usableWidth);

    final ratio = x / usableWidth;

    final angle = minAngle + ratio * (maxAngle - minAngle);

    final rounded = angle.round();

    setState(() {
      value = rounded.toDouble();
    });

    widget.onChanged(rounded);
  }

  void release() {
    setState(() {
      value = centerAngle.toDouble();
    });

    widget.onChanged(centerAngle);
    if (widget.onReleased != null) {
      widget.onReleased!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Kullanılabilir genişlik
        final usableWidth = width - (horizontalMargin * 2);

        final ratio = (value - minAngle) / (maxAngle - minAngle);

        // Topuzun merkeze göre konum hesabı
        final knobLeft = horizontalMargin + ratio * usableWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            updateFromPosition(
              details.localPosition,
              constraints,
            );
          },
          onPanUpdate: (details) {
            updateFromPosition(
              details.localPosition,
              constraints,
            );
          },
          onPanEnd: (_) {
            release();
          },
          onPanCancel: release,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ==========================================
              // BÜYÜK DEĞER
              // ==========================================
              Text(
                '${value.round()}°',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // SLIDER
              // ==========================================
              SizedBox(
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ray (Kenarlara Neredeyse Sıfır)
                    Positioned(
                      left: horizontalMargin,
                      right: horizontalMargin,
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF292F38),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white10,
                            width: 1,
                          ),
                        ),
                      ),
                    ),

                    // Merkez işareti
                    Positioned(
                      left: width / 2 - 2,
                      child: Container(
                        width: 4,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),

                    // Topuz (Knob - 60px genişliğinde, merkeze hizalamak için -30 px kaydırılıyor)
                    Positioned(
                      left: knobLeft - 30,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 20,
                              spreadRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Derece sınırları
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: horizontalMargin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      '30°',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '60°',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '90°',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}