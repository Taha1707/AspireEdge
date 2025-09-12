import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final List<Color> colors;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Size? minimumSize;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.colors = const [Color(0xFF667EEA), Color(0xFF764BA2)],
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.minimumSize,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            padding: padding,
            minimumSize: minimumSize ?? const Size(120, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white70,
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          child:
              isLoading
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Saving...'),
                    ],
                  )
                  : child,
        ),
      ),
    );
  }
}
