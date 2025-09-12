import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureCardTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const FeatureCardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<FeatureCardTile> createState() => _FeatureCardTileState();
}

class _FeatureCardTileState extends State<FeatureCardTile> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _pressed ? 0.98 : (_hovering ? 1.02 : 1.0);
    final List<BoxShadow> shadow = [
      BoxShadow(
        color: Colors.black.withOpacity(_hovering ? 0.35 : 0.25),
        blurRadius: _hovering ? 22 : 16,
        offset: const Offset(0, 8),
      ),
    ];

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      transform: Matrix4.identity()..scale(scale),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadow,
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool tight =
              constraints.maxHeight <= 64 || constraints.maxWidth <= 320;
          final double iconSize = tight ? 20 : 24;
          final double tileSide = tight ? 40 : 44;
          final double titleSize = tight ? 14 : 16;
          final double subSize = tight ? 10.5 : 12;
          final bool showSubtitle =
              constraints.maxHeight > 56 && constraints.maxWidth > 300;

          return Row(
            children: [
              Container(
                width: tileSide,
                height: tileSide,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: iconSize),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (showSubtitle) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Manage & view details',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: subSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: tight ? 24 : 28,
                height: tight ? 24 : 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: tight ? 12 : 14,
                  color: Colors.white70,
                ),
              ),
            ],
          );
        },
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: card,
      ),
    );
  }
}
