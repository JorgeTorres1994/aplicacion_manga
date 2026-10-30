import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KuroTheme {
  // Brand Colors
  static const Color background = Color(0xFF090A0E);
  static const Color backgroundSecondary = Color(0xFF0F1117);
  static const Color card = Color(0xFF141721);
  static const Color cardLighter = Color(0xFF1B1F2D);
  static const Color cardSelected = Color(0xFF23283A);
  static const Color border = Color(0xFF25293A);
  static const Color borderSubtle = Color(0xFF1C202E);

  // Accent Colors
  static const Color crimson = Color(0xFFE51943);
  static const Color crimsonGlow = Color(0xFFFF2A55);
  static const Color crimsonDark = Color(0xFF8B0E28);
  static const Color crimsonLightBg = Color(0x2AE51943);

  static const Color cyan = Color(0xFF00E5FF);
  static const Color cyanDark = Color(0xFF00838F);
  static const Color purple = Color(0xFF9D4EDD);
  static const Color gold = Color(0xFFFFB703);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFF9100);

  // Text Colors
  static const Color textWhite = Color(0xFFF5F6F9);
  static const Color textGrey = Color(0xFF9EA3B5);
  static const Color textMuted = Color(0xFF5B6175);
  static const Color textMonochrome = Color(0xFFE2E4EC);

  // Gradients
  static const LinearGradient crimsonGradient = LinearGradient(
    colors: [Color(0xFFF5224F), Color(0xFFD0103A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF171A24), Color(0xFF12141C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroOverlayGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x80090A0E),
      Color(0xF0090A0E),
      Color(0xFF090A0E),
    ],
    stops: [0.0, 0.4, 0.75, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Typography
  static TextStyle mono({
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w600,
    Color color = textMuted,
    double letterSpacing = 1.0,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle title({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w800,
    Color color = textWhite,
    double letterSpacing = -0.5,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = textGrey,
    double height = 1.4,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // Box Decorations
  static BoxDecoration cardDecoration({
    Color? color,
    Color? borderColor,
    double radius = 14,
    bool glow = false,
  }) {
    return BoxDecoration(
      color: color ?? card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? border,
        width: 1,
      ),
      boxShadow: glow
          ? [
              BoxShadow(
                color: crimson.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            ]
          : null,
    );
  }

  // Status Badge Widget Helper
  static Widget badge({
    required String text,
    Color bgColor = crimson,
    Color textColor = Colors.white,
    IconData? icon,
    bool isMono = true,
    double fontSize = 9.5,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: isMono
                ? GoogleFonts.jetBrainsMono(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 0.5,
                  )
                : GoogleFonts.spaceGrotesk(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 0.3,
                  ),
          ),
        ],
      ),
    );
  }

  // Glow Button Helper
  static Widget primaryButton({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
    bool isLoading = false,
    double height = 52,
    double fontSize = 13,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: crimsonGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: crimson.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isLoading ? null : onTap,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(icon, size: 16, color: Colors.white),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
