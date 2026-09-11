import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class MajesticHorizonTheme {
  // Brand Colors - Light Mode
  static const Color lightPrimaryNavy = Color(0xFF052469);
  static const Color lightAccentGold = Color(0xFF78592E);
  static const Color lightBackground = Color(0xFFF9F9FF);
  static const Color lightSurfaceCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF171C26);
  static const Color lightTextMuted = Color(0xFF444650);
  static const Color lightBorder = Color(0xFFE5E7F0);
  static const Color lightActiveStatus = Color(0xFF2E7D32);
  static const Color lightActiveChipBg = Color(0xFFE8F5E9);

  // Brand Colors - Dark Mode
  static const Color darkPrimaryNavy = Color(0xFF93A9F5);
  static const Color darkAccentGold = Color(0xFFFED39D);
  static const Color darkBackground = Color(0xFF171C26);
  static const Color darkSurfaceCard = Color(0xFF2B303C);
  static const Color darkTextPrimary = Color(0xFFEDF0FF);
  static const Color darkTextMuted = Color(0xFFA2A7B8);
  static const Color darkBorder = Color(0xFF444650);

  // Shape Geometries
  static final BorderRadius radiusButton = BorderRadius.circular(4.0);
  static final BorderRadius radiusInput = BorderRadius.circular(4.0);
  static final BorderRadius radiusCard = BorderRadius.circular(8.0);
  static final BorderRadius radiusHero = BorderRadius.circular(12.0);
  static final BorderRadius radiusPill = BorderRadius.circular(999.0);

  // Elevation Shadows
  static const List<BoxShadow> lightCardShadow = [
    BoxShadow(
      color: Color.fromRGBO(36, 60, 128, 0.06),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> darkCardShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.25),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];

  // Light Theme Data
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.hankenGroteskTextTheme();
    final headerTextTheme = GoogleFonts.montserratTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: lightPrimaryNavy,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: lightPrimaryNavy,
        secondary: lightAccentGold,
        surface: lightSurfaceCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        outline: lightBorder,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: headerTextTheme.displayLarge?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: headerTextTheme.displayMedium?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: headerTextTheme.headlineLarge?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: headerTextTheme.headlineMedium?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: headerTextTheme.headlineSmall?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: headerTextTheme.titleLarge?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: headerTextTheme.titleMedium?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: headerTextTheme.titleSmall?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: lightTextPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: lightTextPrimary,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: lightTextMuted,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurfaceCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: lightPrimaryNavy),
        titleTextStyle: GoogleFonts.montserrat(
          color: lightPrimaryNavy,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radiusCard,
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: radiusButton,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightPrimaryNavy,
          side: const BorderSide(color: lightPrimaryNavy, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: radiusButton,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: radiusInput,
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusInput,
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusInput,
          borderSide: const BorderSide(color: lightPrimaryNavy, width: 1.5),
        ),
        hintStyle: GoogleFonts.hankenGrotesk(
          color: lightTextMuted,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.hankenGrotesk(
          color: lightTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Dark Theme Data
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.hankenGroteskTextTheme(ThemeData.dark().textTheme);
    final headerTextTheme = GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimaryNavy,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimaryNavy,
        secondary: darkAccentGold,
        surface: darkSurfaceCard,
        onPrimary: darkBackground,
        onSecondary: darkBackground,
        onSurface: darkTextPrimary,
        outline: darkBorder,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: headerTextTheme.displayLarge?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: headerTextTheme.displayMedium?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: headerTextTheme.headlineLarge?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: headerTextTheme.headlineMedium?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: headerTextTheme.headlineSmall?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: headerTextTheme.titleLarge?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: headerTextTheme.titleMedium?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: headerTextTheme.titleSmall?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: darkTextPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: darkTextPrimary,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: darkTextMuted,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurfaceCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: GoogleFonts.montserrat(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radiusCard,
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryNavy,
          foregroundColor: darkBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: radiusButton,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimaryNavy,
          side: const BorderSide(color: darkPrimaryNavy, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: radiusButton,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: radiusInput,
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusInput,
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusInput,
          borderSide: const BorderSide(color: darkPrimaryNavy, width: 1.5),
        ),
        hintStyle: GoogleFonts.hankenGrotesk(
          color: darkTextMuted,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.hankenGrotesk(
          color: darkTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
