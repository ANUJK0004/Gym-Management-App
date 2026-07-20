import 'package:flutter/widgets.dart';

class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 28;
  static const double circular = 999;

  static const BorderRadius radiusXS =
  BorderRadius.all(Radius.circular(xs));

  static const BorderRadius radiusSM =
  BorderRadius.all(Radius.circular(sm));

  static const BorderRadius radiusMD =
  BorderRadius.all(Radius.circular(md));

  static const BorderRadius radiusLG =
  BorderRadius.all(Radius.circular(lg));

  static const BorderRadius radiusXL =
  BorderRadius.all(Radius.circular(xl));

  static const BorderRadius radiusXXL =
  BorderRadius.all(Radius.circular(xxl));

  static const BorderRadius circularRadius =
  BorderRadius.all(Radius.circular(circular));
}