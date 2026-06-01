abstract final class RequestTimeout {
  const RequestTimeout._();

  static const normal = Duration(seconds: 6);
  static const upload = Duration(seconds: 30);
}
