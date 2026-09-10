import 'package:flutter/material.dart';

/// Centralized clinical palette adhering to Stitch DESIGN.md tokens.
/// Calibrated for high contrast, accessibility, and trustworthy healthcare aesthetics.
class AppColors {
  AppColors._();

  // Primary Accent (Deep Clinical Teal)
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryContainer = Color(0xFFCCFBF1); // Soft Teal Mint
  static const Color primaryWhisper = Color(0xFFF0FDFA); // Ultra-light tint for AI bubbles

  // Secondary & Accents
  static const Color secondary = Color(0xFF0284C7); // Clinical Sky
  static const Color secondaryContainer = Color(0xFFE0F2FE);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate-50 Canvas
  static const Color surface = Color(0xFFFFFFFF); // Pure Surface
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate-100

  // Typography / Ink
  static const Color textPrimary = Color(0xFF0F172A); // Charcoal Slate-900
  static const Color textSecondary = Color(0xFF64748B); // Muted Steel Slate-500
  static const Color textMuted = Color(0xFF94A3B8); // Slate-400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Structural & Borders
  static const Color border = Color(0xFFE2E8F0); // Whisper Border Slate-200
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Status & Semantic Feedback
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444); // Rose / Danger
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoContainer = Color(0xFFDBEAFE);

  // Chat Bubble specifics
  static const Color patientBubble = Color(0xFF0D9488);
  static const Color aiBubble = Color(0xFFF0FDFA);
  static const Color aiBubbleBorder = Color(0xFFCCFBF1);
}
