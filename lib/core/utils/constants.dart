import 'package:flutter_dotenv/flutter_dotenv.dart';

/// BASE_URL و TOKEN يجري تحميلهما من ملف .env (غير مرفوع على Git).
final String kBaseUrl      = dotenv.env['BASE_URL'] ??
    'https://oupoun-test-272677622251.me-central1.run.app/api/v2/';
final String kDefaultToken = dotenv.env['TOKEN'] ?? '';      // اتركه فارغًا في التطوير

const Duration kConnectTimeout  = Duration(seconds: 15);
const Duration kReceiveTimeout  = Duration(seconds: 20);
