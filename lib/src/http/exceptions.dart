class RouteNotFoundException implements Exception {
  
  final String path;
  final String method;
  
  const RouteNotFoundException(this.path, this.method);

  @override
  String toString() => "Cannot ${method} ${path}.";

}