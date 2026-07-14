import 'package:flutter/material.dart';

abstract final class GrowlyColors {
  static const brand = Color(0xFF167C80);
  static const brandPressed = Color(0xFF0E5E62);
  static const brandSoft = Color(0xFFDDF4F1);
  static const accent = Color(0xFFF49B45);
  static const accentSoft = Color(0xFFFFE7D0);
  static const reward = Color(0xFFF4C84A);
  static const rewardSoft = Color(0xFFFFF1BD);
  static const imagination = Color(0xFF8267C7);
  static const imaginationSoft = Color(0xFFEDE7FB);
  static const success = Color(0xFF2F8F65);
  static const successSoft = Color(0xFFDDF3E8);
  static const help = Color(0xFF3979B8);
  static const helpSoft = Color(0xFFDDEBFA);
  static const danger = Color(0xFFC9505A);
  static const canvas = Color(0xFFF7F4EC);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF193334);
  static const inkMuted = Color(0xFF607273);
  static const outline = Color(0xFFD9E1DD);
  static const disabled = Color(0xFFB8C3BF);
}

abstract final class GrowlySpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
}

abstract final class GrowlyRadii {
  static const sm = 12.0;
  static const md = 18.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const pill = 999.0;
}

abstract final class GrowlyMotion {
  static const press = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 220);
  static const celebration = Duration(milliseconds: 420);
  static const curve = Curves.easeOutCubic;

  static bool reduce(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}
