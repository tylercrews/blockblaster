import 'package:flutter/material.dart';

/// Color palette derived from the CMYK color wheel.
///
/// Hues follow the wheel clockwise: Red → Vermillion → Orange → Amber →
/// Yellow → Chartreuse → Green → Spring Green → Cyan → Sky Blue → Blue →
/// Indigo → Violet → Magenta → Pink.
///
/// Each [ColorFamily] contains 5 shades ordered lightest → darkest (index 0–4).
/// [ColorFamily.preview] returns index 2 (the pure/medium shade) for use
/// as a compact family chip in a color selector.
///
/// [grayscale] provides 10 steps from white (index 0) to black (index 9).

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class ColorFamily {
  final String name;

  /// 5 shades: 0 = very light, 1 = light, 2 = medium (pure), 3 = dark, 4 = very dark.
  final List<Color> shades;

  const ColorFamily({required this.name, required this.shades});

  /// Representative swatch for family preview chips.
  Color get preview => shades[2];

  /// Convenience accessors.
  Color get veryLight => shades[0];
  Color get light => shades[1];
  Color get medium => shades[2];
  Color get dark => shades[3];
  Color get veryDark => shades[4];
}

// ---------------------------------------------------------------------------
// Color families  (CMYK → hex conversion, K=0 is medium, K=30/60 darken,
//                  reduced chroma lightens toward white)
// ---------------------------------------------------------------------------

const List<ColorFamily> colorFamilies = [
  // --- Reds / Warm -----------------------------------------------------------
  ColorFamily(
    name: 'Red',          // CMYK base: 0, 100, 100, 0
    shades: [
      Color(0xFFFFCCCC),  // very light
      Color(0xFFFF8080),  // light
      Color(0xFFFF0000),  // medium  ← pure red
      Color(0xFFB30000),  // dark
      Color(0xFF660000),  // very dark
    ],
  ),
  ColorFamily(
    name: 'Vermillion',   // CMYK base: 0, 65, 100, 0
    shades: [
      Color(0xFFFFDECC),
      Color(0xFFFFAB80),
      Color(0xFFFF5900),
      Color(0xFFB33E00),
      Color(0xFF662400),
    ],
  ),
  ColorFamily(
    name: 'Orange',       // CMYK base: 0, 40, 100, 0
    shades: [
      Color(0xFFFFEBCC),
      Color(0xFFFFCC80),
      Color(0xFFFF9900),
      Color(0xFFB36B00),
      Color(0xFF663D00),
    ],
  ),
  ColorFamily(
    name: 'Amber',        // CMYK base: 0, 20, 100, 0
    shades: [
      Color(0xFFFFF5CC),
      Color(0xFFFFE680),
      Color(0xFFFFCC00),
      Color(0xFFB38F00),
      Color(0xFF665200),
    ],
  ),

  // --- Yellows / Greens ------------------------------------------------------
  ColorFamily(
    name: 'Yellow',       // CMYK base: 0, 0, 100, 0
    shades: [
      Color(0xFFFFFFCC),
      Color(0xFFFFFF80),
      Color(0xFFFFFF00),
      Color(0xFFB3B300),
      Color(0xFF666600),
    ],
  ),
  ColorFamily(
    name: 'Chartreuse',   // CMYK base: 25, 0, 100, 0
    shades: [
      Color(0xFFF2FFCC),
      Color(0xFFDEFF80),
      Color(0xFFBFFF00),
      Color(0xFF86B300),
      Color(0xFF4C6600),
    ],
  ),
  ColorFamily(
    name: 'Green',        // CMYK base: 100, 0, 100, 0
    shades: [
      Color(0xFFCCFFCC),
      Color(0xFF80FF80),
      Color(0xFF00FF00),
      Color(0xFF00B300),
      Color(0xFF006600),
    ],
  ),
  ColorFamily(
    name: 'Spring Green', // CMYK base: 100, 0, 50, 0
    shades: [
      Color(0xFFCCFFE6),
      Color(0xFF80FFBF),
      Color(0xFF00FF80),
      Color(0xFF00B359),
      Color(0xFF006633),
    ],
  ),

  // --- Blues / Cyans ---------------------------------------------------------
  ColorFamily(
    name: 'Cyan',         // CMYK base: 100, 0, 0, 0
    shades: [
      Color(0xFFCCFFFF),
      Color(0xFF80FFFF),
      Color(0xFF00FFFF),
      Color(0xFF00B3B3),
      Color(0xFF006666),
    ],
  ),
  ColorFamily(
    name: 'Sky Blue',     // CMYK base: 100, 40, 0, 0
    shades: [
      Color(0xFFCCEBFF),
      Color(0xFF80CCFF),
      Color(0xFF0099FF),
      Color(0xFF006BB3),
      Color(0xFF003D66),
    ],
  ),
  ColorFamily(
    name: 'Blue',         // CMYK base: 100, 60, 0, 0
    shades: [
      Color(0xFFCCE0FF),
      Color(0xFF80B3FF),
      Color(0xFF0066FF),
      Color(0xFF0047B3),
      Color(0xFF002966),
    ],
  ),
  ColorFamily(
    name: 'Indigo',       // CMYK base: 80, 100, 0, 0
    shades: [
      Color(0xFFD6CCFF),
      Color(0xFF9980FF),
      Color(0xFF3300FF),
      Color(0xFF2400B3),
      Color(0xFF140066),
    ],
  ),

  // --- Purples / Pinks -------------------------------------------------------
  ColorFamily(
    name: 'Violet',       // CMYK base: 40, 100, 0, 0
    shades: [
      Color(0xFFEBCCFF),
      Color(0xFFCC80FF),
      Color(0xFF9900FF),
      Color(0xFF6B00B3),
      Color(0xFF3D0066),
    ],
  ),
  ColorFamily(
    name: 'Magenta',      // CMYK base: 0, 100, 0, 0
    shades: [
      Color(0xFFFFCCFF),
      Color(0xFFFF80FF),
      Color(0xFFFF00FF),
      Color(0xFFB300B3),
      Color(0xFF660066),
    ],
  ),
  ColorFamily(
    name: 'Pink',         // CMYK base: 0, 100, 20, 0
    shades: [
      Color(0xFFFFCCF5),
      Color(0xFFFF80E6),
      Color(0xFFFF00CC),
      Color(0xFFB3008F),
      Color(0xFF660052),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Grayscale  (10 steps, index 0 = white, index 9 = black)
// ---------------------------------------------------------------------------

const List<Color> grayscale = [
  Color(0xFFFFFFFF), // White
  Color(0xFFE6E6E6),
  Color(0xFFCCCCCC),
  Color(0xFFB3B3B3),
  Color(0xFF999999),
  Color(0xFF808080),
  Color(0xFF666666),
  Color(0xFF4D4D4D),
  Color(0xFF333333),
  Color(0xFF000000), // Black
];

// ---------------------------------------------------------------------------
// Convenience helpers
// ---------------------------------------------------------------------------

/// All selectable colors as a flat list: every shade of every family,
/// followed by grayscale.  Useful for simple grid-style pickers.
List<Color> get allColors => [
      for (final family in colorFamilies) ...family.shades,
      ...grayscale,
    ];

/// Look up a [ColorFamily] by name (case-sensitive).
ColorFamily? colorFamilyByName(String name) {
  try {
    return colorFamilies.firstWhere((f) => f.name == name);
  } catch (_) {
    return null;
  }
}
