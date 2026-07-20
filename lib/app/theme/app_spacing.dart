import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double massive = 64;

  static const SizedBox vXXS = SizedBox(height: xxs);
  static const SizedBox vXS = SizedBox(height: xs);
  static const SizedBox vSM = SizedBox(height: sm);
  static const SizedBox vMD = SizedBox(height: md);
  static const SizedBox vLG = SizedBox(height: lg);
  static const SizedBox vXL = SizedBox(height: xl);
  static const SizedBox vXXL = SizedBox(height: xxl);

  static const SizedBox hXXS = SizedBox(width: xxs);
  static const SizedBox hXS = SizedBox(width: xs);
  static const SizedBox hSM = SizedBox(width: sm);
  static const SizedBox hMD = SizedBox(width: md);
  static const SizedBox hLG = SizedBox(width: lg);
  static const SizedBox hXL = SizedBox(width: xl);
  static const SizedBox hXXL = SizedBox(width: xxl);
}