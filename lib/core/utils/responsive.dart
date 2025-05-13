import 'package:flutter/material.dart';

enum ScreenType { phone, tabletSmall, tabletLarge, desktop, tv }

ScreenType screenType(BuildContext c) {
  final w = MediaQuery.of(c).size.width;
  if (w <= 450) return ScreenType.phone;
  if (w <= 800) return ScreenType.tabletSmall;
  if (w <= 1200) return ScreenType.tabletLarge;
  if (w <= 1800) return ScreenType.desktop;
  return ScreenType.tv;         // شاشات 25–32 بوصة +
}

int crossAxisCount(BuildContext c) {
  switch (screenType(c)) {
    case ScreenType.phone:        return 1;
    case ScreenType.tabletSmall:  return 2;
    case ScreenType.tabletLarge:  return 3;
    case ScreenType.desktop:      return 4;
    case ScreenType.tv:           return 6;
  }
}
