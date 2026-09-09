import 'package:flutter/material.dart';

class ThrottleSlider extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final VoidCallback onReleased;
  final int initialValue;

  const ThrottleSlider({
    super.key,
    required this.onChanged,
    required this.onReleased,
    this.initialValue = 0,
  });

  @override
  State<ThrottleSlider> createState() =>
      _ThrottleSliderState();
}

class _ThrottleSliderState
    extends State<ThrottleSlider> {

  late double value;

  @override
  void initState() {
    super.initState();

    value = widget.initialValue
        .toDouble()
        .clamp(-100, 100);
  }

  void updateFromPosition(
    Offset position,
    BoxConstraints constraints,
  ) {
    final height = constraints.maxHeight;

    if (height <= 0) return;

    final y = position.dy.clamp(
      0.0,
      height,
    );

    final center = height / 2;

    double result;

    if (y < center) {
      final ratio =
          (center - y) / center;

      result = ratio * 100;
    } else {
      final ratio =
          (y - center) / center;

      result = -ratio * 100;
    }

    

    result = result.clamp(-100, 100);

    setState(() {
      value = result;
    });

    widget.onChanged(
      result.round(),
    );
  }

  void release() {
    setState(() {
      value = 0;
    });

    widget.onReleased();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final height =
            constraints.maxHeight;

        final center =
            height / 2;

        final knobCenter =
            center -
            (value / 100) * center;

        return GestureDetector(
          behavior:
              HitTestBehavior.opaque,

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

          child: Stack(
            alignment: Alignment.center,
          
            children: [
          
              // ==========================================
              // ANA RAY
              // ==========================================
          
              Container(
                width: 130,
          
                
          
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFF292F38,
                  ),
          
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
          
                  border: Border.all(
                    color:
                        Colors.white10,
                    width: 1,
                  ),
                ),
              ),
          
              // ==========================================
              // MERKEZ ÇİZGİSİ
              // ==========================================
          
              Positioned(
                top: center - 2,
          
                child: Container(
                  width: 60,
                  height: 4,
          
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white38,
          
                    borderRadius:
                        BorderRadius.circular(
                      5,
                    ),
                  ),
                ),
              ),
          
              // ==========================================
              // ÜST "+" BÖLGE
              // ==========================================
          
              Positioned(
                top: 4,
                child: Text(
                  '+100',
                  style:
                      const TextStyle(
                    color:
                        Colors.white38,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
          
              // ==========================================
              // ALT "-" BÖLGE
              // ==========================================
          
              Positioned(
                bottom: 4,
                child: Text(
                  '-100',
                  style:
                      const TextStyle(
                    color:
                        Colors.white38,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
          
              // ==========================================
              // MERKEZ 0
              // ==========================================
          
              
          
              // ==========================================
              // KNOB
              // ==========================================
          
              Positioned(
                top: knobCenter - 30,
          
                child: Container(
                  width: 60,
                  height: 60,
          
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
          
                    shape:
                        BoxShape.circle,
          
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 20,
                        spreadRadius: 3,
                        color:
                            Colors.black54,
                      ),
                    ],
                  ),
          
                  child: Center(
                    child: Text(
                      value.round()
                          .toString(),
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF11151C),
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}