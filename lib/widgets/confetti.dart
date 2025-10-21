import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiWidget extends StatefulWidget {
  const ConfettiWidget({Key? key}) : super(key: key);

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Confetti> confetti;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    confetti = List.generate(50, (index) => Confetti());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(time: _controller.value, confetti: confetti),
          child: Container(),
        );
      },
    );
  }
}

class Confetti {
  final Color color;
  final double dx;
  final double dy;
  final double size;
  final double velocity;

  Confetti()
    : color = Colors.primaries[Random().nextInt(Colors.primaries.length)],
      dx = Random().nextDouble(),
      dy = Random().nextDouble(),
      size = Random().nextDouble() * 8 + 2,
      velocity = Random().nextDouble() * 2 + 1;
}

class ConfettiPainter extends CustomPainter {
  final double time;
  final List<Confetti> confetti;

  ConfettiPainter({required this.time, required this.confetti});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in confetti) {
      final paint = Paint()..color = particle.color;
      final position = Offset(
        particle.dx * size.width,
        (particle.dy + time * particle.velocity) % 1 * size.height,
      );
      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
