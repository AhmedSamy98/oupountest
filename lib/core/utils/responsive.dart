import 'package:flutter/material.dart';

enum DeviceScreenType { mobile, tablet, desktop, tv }

class Responsive {
  static DeviceScreenType type(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 600) return DeviceScreenType.mobile;
    if (w < 1024) return DeviceScreenType.tablet;
    if (w < 1920) return DeviceScreenType.desktop;
    return DeviceScreenType.tv;
  }

  static int gridColumns(BuildContext context) {
    switch (type(context)) {
      case DeviceScreenType.mobile:  return 1;
      case DeviceScreenType.tablet:  return 2;
      case DeviceScreenType.desktop: return 4;
      case DeviceScreenType.tv:      return 6;
    }
  }
}

/// ملحقات سريعة على BuildContext
extension ResponsiveExt on BuildContext {
  DeviceScreenType get device       => Responsive.type(this);
  bool get isMobile  => device == DeviceScreenType.mobile;
  bool get isTablet  => device == DeviceScreenType.tablet;
  bool get isDesktop => device == DeviceScreenType.desktop;
}

// ... الملف كما أرسلته سابقًا صالح، وهذه إضافة اختيارية:
extension MediaQueryExt on BuildContext {
  double get width  => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;
}
