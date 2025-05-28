// import 'package:flutter_dotenv/flutter_dotenv.dart';

/// BASE_URL و TOKEN يجري تحميلهما من ملف .env (غير مرفوع على Git).
// final String kBaseUrl      = dotenv.env['BASE_URL'] ??
//     'https://oupoun-test-272677622251.me-central1.run.app/api/v2/';

final String kBaseUrl      = 'https://oupoun-test-272677622251.me-central1.run.app/api/v2/';
// final String kBaseUrl      = 'https://oupoun-prod-950806530545.me-central1.run.app/api/v2/';

// final String kDefaultToken = dotenv.env['TOKEN'] ?? '';      // اتركه فارغًا في التطوير

final String kDefaultToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2ODExZmIwYTk5OGUwMThiN2NmMGQwOWMiLCJyb2xlIjoiYWRtaW4iLCJkZXZpY2VfaWQiOiIxMjM0IiwiZGV2aWNlX29zIjoiYW5kcm9pZCIsImV4cCI6MTc1MTAzMzAwM30.PgSRwGk5AThPHQfrXUpJSBu-63b6Syq3GXamlw3t15w';
// final String kDefaultToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2ODBmOGJiZTM3MzBlODY2NTgwMGY5NWQiLCJyb2xlIjoiYWRtaW4iLCJkZXZpY2VfaWQiOiIxMjM0IiwiZGV2aWNlX29zIjoid2ViIiwiZXhwIjoxNzUxMDM1NjAxfQ.eVVu9GZ-6mtbbbt7i3DB62z_NgQ4cpoz60KqtUt8fmU';

const Duration kConnectTimeout  = Duration(seconds: 15);
const Duration kReceiveTimeout  = Duration(seconds: 20);
