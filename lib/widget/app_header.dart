import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showLogo;

  const AppHeader({
    super.key,
    this.title,
    this.actions,
    this.showLogo = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(70.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            const Color(0xFF0A0A1A),
            Colors.black,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4FF).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Blue light streak effect
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF00B4FF).withOpacity(0.4),
                    const Color(0xFF0066FF).withOpacity(0.6),
                    const Color(0xFF00B4FF).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4FF).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                children: [
                  // Back button (only show if can pop)
                  if (Navigator.of(context).canPop()) ...[
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  // Logo/Brand Section
                  if (showLogo)
                    Expanded(
                      child: Row(
                        children: [
                          // Logo Image
                        /*  Image.asset(
                            'assets/splash_logo.png',
                            height: 35.h,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 35.w,
                                height: 35.w,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF0066FF),
                                      const Color(0xFF00B4FF),
                                      Colors.grey[300]!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.abc,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 10.w),*/
                          // Brand Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title ?? 'BYTE BOX',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFF00B4FF).withOpacity(0.5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (title == null || title == 'BYTE BOX') ...[
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Smart Tech. Smart Price.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.sp,
                                      color: Colors.white70,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: Text(
                        title ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF00B4FF).withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // Actions
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
