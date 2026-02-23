import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys and typed accessors for all persisted user settings.
///
/// Usage:
///   await LocalStorageProperties.init();          // call once at app start
///   final color = LocalStorageProperties.getColor(3); // Color? for slot 3
///   await LocalStorageProperties.setColor(3, Colors.blue);
///   final sens = LocalStorageProperties.turnSensitivity; // double
///   await LocalStorageProperties.setTurnSensitivity(2.5);

abstract class LocalStorageProperties {
  // ---------------------------------------------------------------------------
  // Keys
  // ---------------------------------------------------------------------------
  static const String _keyColor1  = 'color1';
  static const String _keyColor2  = 'color2';
  static const String _keyColor3  = 'color3';
  static const String _keyColor4  = 'color4';
  static const String _keyColor5  = 'color5';
  static const String _keyColor6  = 'color6';
  static const String _keyColor7  = 'color7';
  static const String _keyColor8  = 'color8';
  static const String _keyColor9  = 'color9';
  static const String _keyColor10 = 'color10';
  static const String _keyTurnSensitivity = 'turn_sensitivity';

  static const List<String> _colorKeys = [
    '',          // index 0 unused (aligns with defaultColors[0] = null)
    _keyColor1,
    _keyColor2,
    _keyColor3,
    _keyColor4,
    _keyColor5,
    _keyColor6,
    _keyColor7,
    _keyColor8,
    _keyColor9,
    _keyColor10,
  ];

  // ---------------------------------------------------------------------------
  // Defaults
  // ---------------------------------------------------------------------------
  static const double defaultTurnSensitivity = 4.0;

  // ---------------------------------------------------------------------------
  // Internal state
  // ---------------------------------------------------------------------------
  static SharedPreferences? _prefs;

  /// Must be called (and awaited) once before using any property.
  /// Typically called in [main()] before [runApp()].
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    assert(_prefs != null,
        'LocalStorageProperties.init() must be awaited before accessing properties.');
    return _prefs!;
  }

  // ---------------------------------------------------------------------------
  // Color slots 1–10
  // ---------------------------------------------------------------------------

  /// Returns the stored [Color] for the given [slot] (1–10), or null if unset.
  static Color? getColor(int slot) {
    assert(slot >= 1 && slot <= 10, 'Color slot must be 1–10.');
    final value = _p.getInt(_colorKeys[slot]);
    return value != null ? Color(value) : null;
  }

  /// Persists [color] for the given [slot] (1–10).
  /// Pass null to clear the slot.
  static Future<void> setColor(int slot, Color? color) async {
    assert(slot >= 1 && slot <= 10, 'Color slot must be 1–10.');
    if (color == null) {
      await _p.remove(_colorKeys[slot]);
    } else {
      await _p.setInt(_colorKeys[slot], color.toARGB32());
    }
  }

  /// Clears all stored color slots.
  static Future<void> clearColors() async {
    for (int i = 1; i <= 10; i++) {
      await _p.remove(_colorKeys[i]);
    }
  }

  // ---------------------------------------------------------------------------
  // Turn sensitivity
  // ---------------------------------------------------------------------------

  /// Returns the stored turn sensitivity, or [defaultTurnSensitivity] if unset.
  static double get turnSensitivity =>
      _p.getDouble(_keyTurnSensitivity) ?? defaultTurnSensitivity;

  /// Persists [value] as the turn sensitivity.
  static Future<void> setTurnSensitivity(double value) async {
    await _p.setDouble(_keyTurnSensitivity, value);
  }
}
