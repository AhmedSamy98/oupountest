/// أصناف أخطاء مخصّصة لتوحيد المعالجة بين الطبقات.
abstract class Failure implements Exception {
  final String message;
  const Failure(this.message);
  @override
  String toString() => message;
}

class NetworkFailure extends Failure  { const NetworkFailure(String m) : super(m); }
class ServerFailure  extends Failure  { const ServerFailure (String m) : super(m); }
class UnknownFailure extends Failure  { const UnknownFailure(String m) : super(m); }
