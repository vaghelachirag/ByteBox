import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedPercentageBadge extends StatefulWidget {
  final double discount;
  final double top;
  final double right;

  const AnimatedPercentageBadge({
    super.key,
    required this.discount,
    this.top = 8,
    this.right = 8,
  });

  @override
  State<AnimatedPercentageBadge> createState() =>
      _AnimatedPercentageBadgeState();
}

class _AnimatedPercentageBadgeState extends State<AnimatedPercentageBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, -0.1),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // ▶ Auto play on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward().then((_) => _controller.reverse());
    });
  }

  void _onTap() {
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      right: widget.right,
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Transform.scale(
              scale: _scale.value,
              child: Transform.translate(
                offset: Offset(
                  _slide.value.dx * 20,
                  _slide.value.dy * 20,
                ),
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35), // Orange color matching the image
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${widget.discount.toInt()}%",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "OFF",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
