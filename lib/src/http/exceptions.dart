/// Thrown to the [Application]'s error handler when the request path or method doesn't match
/// one of the created routes.
class RouteNotFoundException implements Exception {
  
  final String path;
  final String method;
  
  const RouteNotFoundException(this.path, this.method);

  @override
  String toString() => "Cannot ${method} ${path}.";

}