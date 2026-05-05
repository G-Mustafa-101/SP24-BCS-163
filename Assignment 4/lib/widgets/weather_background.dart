import 'dart:math';
import 'package:flutter/material.dart';

class WeatherBackground extends StatefulWidget {
  final String condition;
  final bool isDay;
  const WeatherBackground({
    super.key,
    required this.condition,
    required this.isDay,
  });

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _rainController;
  late AnimationController _snowController;
  late AnimationController _sunController;
  late AnimationController _cloudController;
  late AnimationController _lightningController;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _snowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000));
    _sunController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _cloudController =
        AnimationController(vsync: this, duration: const Duration(seconds: 25));
    _lightningController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));

    _sunController.repeat(reverse: true);
    _cloudController.repeat();

    if (widget.condition == 'rain' ||
        widget.condition == 'drizzle' ||
        widget.condition == 'thunderstorm') {
      _rainController.repeat();
    }
    if (widget.condition == 'snow') {
      _snowController.repeat();
    }
    if (widget.condition == 'thunderstorm') {
      _scheduleLightning();
    }
  }

  void _scheduleLightning() {
    Future.delayed(Duration(milliseconds: 2000 + _random.nextInt(4000)), () {
      if (mounted && widget.condition == 'thunderstorm') {
        _lightningController.forward(from: 0).then((_) {
          _lightningController.reverse();
        });
        _scheduleLightning();
      }
    });
  }

  @override
  void dispose() {
    _rainController.dispose();
    _snowController.dispose();
    _sunController.dispose();
    _cloudController.dispose();
    _lightningController.dispose();
    super.dispose();
  }

  List<Color> _getGradient() {
    if (!widget.isDay) {
      return [
        const Color(0xFF0a0e1a),
        const Color(0xFF0d1b2a),
        const Color(0xFF1a2744),
        const Color(0xFF0f1a2e)
      ];
    }
    switch (widget.condition) {
      case 'clear':
        return [
          const Color(0xFF1a78c2),
          const Color(0xFF2193db),
          const Color(0xFF56b3f4),
          const Color(0xFF87ceeb)
        ];
      case 'few-clouds':
        return [
          const Color(0xFF1e6fa8),
          const Color(0xFF2a8ec4),
          const Color(0xFF4fb3e8),
          const Color(0xFF7bc8f0)
        ];
      case 'clouds':
        return [
          const Color(0xFF4a5568),
          const Color(0xFF718096),
          const Color(0xFFa0aec0),
          const Color(0xFFcbd5e0)
        ];
      case 'rain':
      case 'drizzle':
        return [
          const Color(0xFF2c3e50),
          const Color(0xFF3d5166),
          const Color(0xFF4a6278),
          const Color(0xFF5e7a8c)
        ];
      case 'thunderstorm':
        return [
          const Color(0xFF1a1a2e),
          const Color(0xFF2d2d44),
          const Color(0xFF3d3d55),
          const Color(0xFF4a4a62)
        ];
      case 'snow':
        return [
          const Color(0xFFa8c5da),
          const Color(0xFFb8d4e6),
          const Color(0xFFcce0ee),
          const Color(0xFFddeef8)
        ];
      case 'mist':
        return [
          const Color(0xFF6b7280),
          const Color(0xFF8896a5),
          const Color(0xFFa0adb8),
          const Color(0xFFb8c5ce)
        ];
      default:
        return [
          const Color(0xFF1a78c2),
          const Color(0xFF2193db),
          const Color(0xFF56b3f4),
          const Color(0xFF87ceeb)
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gradient = _getGradient();

    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
        ),

        // Sun glow
        if ((widget.condition == 'clear' || widget.condition == 'few-clouds') &&
            widget.isDay)
          Positioned(
            top: 60,
            right: 50,
            child: AnimatedBuilder(
              animation: _sunController,
              builder: (context, child) {
                final scale = 1.0 + (_sunController.value * 0.15);
                final opacity = 0.6 + (_sunController.value * 0.3);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(255, 220, 50, opacity),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(255, 215, 0, 0.8),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // Clouds
        if (widget.condition == 'clouds' ||
            widget.condition == 'few-clouds' ||
            widget.condition == 'rain' ||
            widget.condition == 'drizzle' ||
            widget.condition == 'thunderstorm')
          ..._buildClouds(size),

        // Rain
        if (widget.condition == 'rain' ||
            widget.condition == 'drizzle' ||
            widget.condition == 'thunderstorm')
          CustomPaint(
            size: size,
            painter: RainPainter(
              animation: _rainController,
              random: _random,
            ),
          ),

        // Snow
        if (widget.condition == 'snow')
          CustomPaint(
            size: size,
            painter: SnowPainter(
              animation: _snowController,
              random: _random,
            ),
          ),

        // Lightning
        if (widget.condition == 'thunderstorm')
          AnimatedBuilder(
            animation: _lightningController,
            builder: (context, child) {
              return Container(
                color: Colors.white
                    .withValues(alpha: _lightningController.value * 0.5),
              );
            },
          ),

        // Mist overlay
        if (widget.condition == 'mist')
          Container(
            color: const Color.fromRGBO(180, 180, 200, 0.3),
          ),
      ],
    );
  }

  List<Widget> _buildClouds(Size size) {
    final clouds = [
      {'top': -10.0, 'left': -50.0, 'scale': 1.0, 'opacity': 0.5},
      {'top': 60.0, 'left': 100.0, 'scale': 0.7, 'opacity': 0.4},
      {'top': 20.0, 'left': -100.0, 'scale': 1.2, 'opacity': 0.35},
    ];

    return clouds.map((cloud) {
      return Positioned(
        top: cloud['top'] as double,
        left: cloud['left'] as double,
        child: AnimatedBuilder(
          animation: _cloudController,
          builder: (context, child) {
            final offset = _cloudController.value * (size.width + 400) - 200;
            return Transform.translate(
              offset: Offset(offset, 0),
              child: Transform.scale(
                scale: cloud['scale'] as double,
                child: Opacity(
                  opacity: cloud['opacity'] as double,
                  child: CustomPaint(
                    size: const Size(140, 60),
                    painter: CloudPainter(),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }
}

class RainPainter extends CustomPainter {
  final Animation<double> animation;
  final Random random;
  List<RainDrop>? drops;

  RainPainter({required this.animation, required this.random})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    drops ??= List.generate(60, (i) => RainDrop(random, size.width));

    final paint = Paint()..style = PaintingStyle.fill;

    for (final drop in drops!) {
      final progress = (animation.value + drop.offset) % 1.0;
      final y = progress * (size.height + 40) - 20;
      paint.color = Color.fromRGBO(174, 214, 241, drop.opacity);
      canvas.save();
      canvas.translate(drop.x, y);
      canvas.rotate(0.17);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 1.5, height: drop.length),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RainDrop {
  final double x;
  final double offset;
  final double opacity;
  final double length;
  RainDrop(Random r, double width)
      : x = r.nextDouble() * width,
        offset = r.nextDouble(),
        opacity = 0.3 + r.nextDouble() * 0.4,
        length = 15 + r.nextDouble() * 20;
}

class SnowPainter extends CustomPainter {
  final Animation<double> animation;
  final Random random;
  List<SnowFlake>? flakes;

  SnowPainter({required this.animation, required this.random})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    flakes ??= List.generate(40, (i) => SnowFlake(random, size.width));

    final paint = Paint()..style = PaintingStyle.fill;

    for (final flake in flakes!) {
      final progress = (animation.value + flake.offset) % 1.0;
      final y = progress * (size.height + 20) - 10;
      final sway = sin(progress * pi * 2) * flake.swayAmount;
      paint.color = const Color.fromRGBO(255, 255, 255, 0.8);
      canvas.drawCircle(
        Offset(flake.x + sway, y),
        flake.size / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SnowFlake {
  final double x;
  final double offset;
  final double size;
  final double swayAmount;
  SnowFlake(Random r, double width)
      : x = r.nextDouble() * width,
        offset = r.nextDouble(),
        size = 3 + r.nextDouble() * 5,
        swayAmount = 20 + r.nextDouble() * 30;
}

class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color.fromRGBO(255, 255, 255, 0.6);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 20, 140, 40),
        const Radius.circular(20),
      ),
      paint,
    );
    canvas.drawCircle(const Offset(40, 10), 25, paint);
    canvas.drawCircle(const Offset(70, 0), 28, paint);
    canvas.drawCircle(const Offset(105, 10), 22, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilderWidget(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedBuilderWidget extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilderWidget({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
