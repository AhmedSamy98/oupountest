// import 'package:logger/logger.dart';
// final log = Logger();

import 'package:logger/logger.dart';

late final Logger log;

void initLogger() {
  log = Logger(
    filter: ProductionFilter(),          // لا يطبع في وضع release
    printer: PrettyPrinter(
      methodCount: 0,
      colors: true,
      printEmojis: true,
    ),
  );
}
