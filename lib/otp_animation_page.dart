import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  late AnimationController _loadingController;
  late AnimationController _mergeController;
  late AnimationController _successController;
  late AnimationController _cardBgController;

  bool _loading = false;
  bool _verified = false;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _mergeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _cardBgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _loadingController.dispose();
    _mergeController.dispose();
    _successController.dispose();
    _cardBgController.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1) {
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _startLoading();
      }
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _startLoading() async {
    final code = _controllers.map((e) => e.text).join();

    if (code.length != 4) return;

    setState(() => _loading = true);
    _loadingController.repeat();

    await Future.delayed(const Duration(milliseconds: 1700));

    _loadingController.stop();
    setState(() => _loading = false);

    await _mergeController.forward();
    await Future.delayed(const Duration(milliseconds: 50));

    _cardBgController.forward();
    setState(() => _verified = true);
    _successController.forward();
  }

  void _reset() {
    for (final c in _controllers) {
      c.clear();
    }

    _loadingController.reset();
    _mergeController.reset();
    _successController.reset();
    _cardBgController.reverse();

    setState(() {
      _loading = false;
      _verified = false;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0a0a0a),
      body: Center(
        child: AnimatedBuilder(
          animation: _cardBgController,
          builder: (context, child) {
            final cardBg = ColorTween(
              begin: const Color(0xff161618),
              end: const Color(0xff0d1f14),
            ).evaluate(_cardBgController)!;

            return Container(
              width: 340,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _verified
                        ? Colors.greenAccent.withOpacity(0.25)
                        : Colors.black.withOpacity(0.25),
                    blurRadius: _verified ? 80 : 35,
                    spreadRadius: _verified ? 12 : 2,
                  ),
                ],
              ),
              child: SizedBox(
                height: 310,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 90,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: _verified ? 0.0 : 1.0,
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 250),
                              offset: _verified
                                  ? const Offset(0, -0.2)
                                  : Offset.zero,
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "دعنا نتحقق من رقمك",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "لقد أرسلنا رمزًا مكونًا من 4 أرقام إلى هاتفك.\nسيتم التحقق تلقائيًا بمجرد إدخاله.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _successController,
                            builder: (context, child) {
                              final textSlide =
                                  Tween<Offset>(
                                        begin: const Offset(0, -0.4),
                                        end: Offset.zero,
                                      )
                                      .animate(
                                        CurvedAnimation(
                                          parent: _successController,
                                          curve: Curves.easeOutBack,
                                        ),
                                      )
                                      .value;

                              return Opacity(
                                opacity: _successController.value,
                                child: FractionalTranslation(
                                  translation: textSlide,
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "تم التحقق بنجاح",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "لقد تم تأكيد رقم هاتفك بنجاح.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Container(
                      height: 90,
                      alignment: Alignment.center,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _mergeController,
                          _successController,
                        ]),
                        builder: (context, child) {
                          final t = Curves.easeInQuad.transform(
                            _mergeController.value,
                          );
                          final blurValue = _verified
                              ? (1 - _successController.value) * 14.0
                              : (t * 14.0).clamp(0.0, 14.0);

                          final boxBorderColor =
                              ColorTween(
                                begin: const Color(0xffff8a3d),
                                end: Colors.greenAccent.withOpacity(0.8),
                              ).evaluate(_cardBgController) ??
                              const Color(0xffff8a3d);

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              ColorFiltered(
                                colorFilter: _mergeController.value > 0.05
                                    ? const ColorFilter.matrix([
                                        1,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        1,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        1,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        18,
                                        -7,
                                      ])
                                    : const ColorFilter.matrix([
                                        1,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        1,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        1,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        1,
                                        0,
                                      ]),
                                child: ImageFiltered(
                                  imageFilter: blurValue > 0.1
                                      ? ImageFilter.blur(
                                          sigmaX: blurValue,
                                          sigmaY: blurValue,
                                        )
                                      : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: _verified
                                        ? [
                                            Container(
                                              width: 66,
                                              height: 66,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: const Color(0xff0f2418),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: boxBorderColor,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ]
                                        : List.generate(4, (index) {
                                            final startX = (index - 1.5) * 72;
                                            final moveX = startX * (1 - t);
                                            final moveY = sin(t * pi) * -12;
                                            final rotate =
                                                ((index - 1.5) * 0.4) *
                                                sin(t * pi);

                                            final isFocused =
                                                _focusNodes[index].hasFocus;

                                            return Transform.translate(
                                              offset: Offset(moveX, moveY),
                                              child: Transform.rotate(
                                                angle: rotate,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    if (isFocused &&
                                                        !_loading &&
                                                        _mergeController
                                                                .value ==
                                                            0)
                                                      Container(
                                                        width: 62,
                                                        height: 62,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                14,
                                                              ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  const Color(
                                                                    0xffff8a3d,
                                                                  ).withOpacity(
                                                                    0.20,
                                                                  ),
                                                              blurRadius: 20,
                                                              spreadRadius: 1.5,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    _OtpCell(
                                                      controller:
                                                          _controllers[index],
                                                      focusNode:
                                                          _focusNodes[index],
                                                      loadingController:
                                                          _loadingController,
                                                      isLoading: _loading,
                                                      index: index,
                                                      onChanged: (v) =>
                                                          _onChanged(v, index),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                  ),
                                ),
                              ),
                              if (_verified)
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.elasticOut,
                                  builder: (context, scale, child) {
                                    return Transform.scale(
                                      scale: scale * _successController.value,
                                      child: Opacity(
                                        opacity: _successController.value.clamp(
                                          0.0,
                                          1.0,
                                        ),
                                        child: const SizedBox(
                                          width: 66,
                                          height: 66,
                                          child: Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 34,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          );
                        },
                      ),
                    ),

                    const Spacer(),

                    GestureDetector(
                      onTap: _verified ? _reset : () {},
                      child: Text(
                        _verified ? "إعادة تعيين" : "إعادة إرسال الرمز",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OtpCell extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final AnimationController loadingController;
  final bool isLoading;
  final int index;
  final ValueChanged<String> onChanged;

  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.loadingController,
    required this.isLoading,
    required this.index,
    required this.onChanged,
  });

  @override
  State<_OtpCell> createState() => _OtpCellState();
}

class _OtpCellState extends State<_OtpCell>
    with SingleTickerProviderStateMixin {
  bool _focused = false;
  late AnimationController _scaleController;
  static const Color orangeColor = Color(0xffff8a3d);

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 1.0,
      upperBound: 1.05,
    );

    widget.focusNode.addListener(() {
      if (mounted) {
        setState(() => _focused = widget.focusNode.hasFocus);
      }
    });

    widget.controller.addListener(() {
      if (widget.controller.text.isNotEmpty) {
        _scaleController.forward().then((_) {
          if (mounted) _scaleController.reverse();
        });
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.controller.text.isNotEmpty;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, widget.loadingController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleController.value,
          child: CustomPaint(
            painter: widget.isLoading
                ? _LoadingBorderPainter(
                    progress: widget.loadingController.value,
                    color: orangeColor,
                    radius: 14,
                  )
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xff1e1e22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  width: 2,
                  color: _focused && !widget.isLoading
                      ? orangeColor
                      : Colors.white10,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(color: Colors.transparent),
                      cursorColor: Colors.transparent,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: widget.onChanged,
                    ),
                  ),
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      transitionBuilder: (child, anim) {
                        return ScaleTransition(
                          scale: anim,
                          child: FadeTransition(opacity: anim, child: child),
                        );
                      },
                      child: hasValue
                          ? Text(
                              widget.controller.text,
                              key: ValueKey(widget.controller.text),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : _focused
                          ? const _BlinkingCursor(key: ValueKey('cursor'))
                          : const SizedBox.shrink(key: ValueKey('empty')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double radius;

  _LoadingBorderPainter({
    required this.progress,
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(
      rect.deflate(1),
      Radius.circular(radius),
    );

    final basePaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.2
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(rRect, basePaint);

    final path = Path()..addRRect(rRect);
    final metric = path.computeMetrics().first;

    final start = metric.length * progress;
    final end = start + metric.length * 0.28;

    Path extractPath;

    if (end <= metric.length) {
      extractPath = metric.extractPath(start, end);
    } else {
      extractPath = Path()
        ..addPath(metric.extractPath(start, metric.length), Offset.zero)
        ..addPath(metric.extractPath(0, end - metric.length), Offset.zero);
    }

    canvas.drawPath(extractPath, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _LoadingBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor({super.key});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
